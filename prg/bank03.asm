; PRG file bank 03, switched in at $8000-$BFFF.
; The sounds. Bank 07 calls this every frame, and writes sound
; when something should play. Six sounds can wait at once.
; A sound uses the two squares, the triangle, and the noise.
; A second set of tracks shares those, and a drum plays on its own.

channels   = $0606     ; which tracks are playing. One bit each.
note_left  = $0607     ; frames left on this note
note_hold  = $0608     ; how long that note is
loud_left  = $0609     ; frames until the loudness changes
loud_level = $060A     ; how loud it is
track      = $0627     ; one track: its notes, loudness, pitch, and where to return
track_tune = $06A7     ; added to the pitch. A higher number is a little lower.
wobble_on  = $06AF     ; the pitch wobbles
pitch_low  = $06B7     ; the note, before it wobbles
pitch_high = $06BF     ; the high byte of that note
fade_left  = $06C7     ; frames until the note gets quieter
fade_load  = $06CF     ; that wait, used again
period_hi  = $06D7     ; high pitch byte last sent. Sending it starts the note over.
sweep_off  = $06DB     ; set while the pitch is not sliding
drum_wait  = $06DF     ; a drum waits while this is set

; --- $8000  Play the sounds. Called every frame.
play_sounds:
        ldx #$05
; The next sound waiting to play.
next_sound:
        ldy sound,x
        beq skip_slot                       ; nothing waiting
        cpy #$25                            ; fade the sound out
        bne play_one
; Sound $25 fades out whatever is playing.
stop_sound:
        lda #$40
        sta fade_left
        sta fade_left+1
        sta fade_left+2
        sta fade_left+3
        sta fade_left+4
        sta fade_left+5
        sta fade_left+6
        sta fade_left+7
        sta fade_load
        sta fade_load+1
        sta fade_load+2
        sta fade_load+3
        sta fade_load+4
        sta fade_load+5
        sta fade_load+6
        sta fade_load+7
        lda #$00
        sta sound,x
        beq play_tracks                     ; always
; This one plays.
play_one:
        jsr start_sound
; Nothing is waiting in this slot.
skip_slot:
        dex
        bpl next_sound
; The waiting sounds are in. Play the tracks.
play_tracks:
        lda #$27
        sta $F0
        lda #$06
        sta $F1
        lda #$00
        sta $F2
        ldy #$08
        sty $F3
; Read this track if its bit is set.
next_track:
        lda channels
        lsr
        bcc save_bits
        ora #$80
; This track's bit moves to the end of the row.
save_bits:
        sta channels
        bcc advance_track                   ; this track is off
        ldx $F2
        dec note_left,x
        bne loudness_step                   ; the note is still going
        jsr read_notes
; The next change in loudness.
loudness_step:
        ldx $F2
        dec loud_left,x
        bne apply_loud                      ; the loudness holds
        ldy #$02
        lda ($F0),y
        sta $F6
        iny
        lda ($F0),y
        sta $F7
        iny
        lda ($F0),y
        pha
        clc
        adc #$02                            ; the next pair in the shape
        sta ($F0),y
        pla
        tay
        lda ($F6),y
        sta loud_left,x
        iny
        lda ($F6),y
        sta loud_level,x
; Use the loudness, whether or not it just changed.
apply_loud:
        jsr note_loudness
; On to the next track.
advance_track:
        clc
        lda #$10
        adc $F0
        sta $F0
        lda #$04
        adc $F2
        sta $F2
        dec $F3
        bne next_track
        lda #$27
        sta $F0
        sta $FC
        lda #$06
        sta $F1
        sta $FD
        lda #$03
        sta $F2
        lda #$11                            ; two tracks share each channel
        sta $F3
; Square, square, triangle, then noise.
next_channel:
        lda channels
        and $F3
        beq advance_channel
        and #$0F
        bne channel_on                      ; the first track on this channel
        clc
        lda #$40                            ; the other track on this channel
        adc $F0
        sta $F0
        lda #$00
        adc $F1
        sta $F1
; Send this channel.
channel_on:
        jsr write_channel
; On to the next channel.
advance_channel:
        clc
        lda #$10
        adc $FC
        sta $FC
        sta $F0
        lda #$00
        adc $FD
        sta $FD
        sta $F1
        asl $F3
        dec $F2
        bpl next_channel
        rts
; --- $80F4  Play this channel.
write_channel:
        lda #$03
        eor $F2                             ; the channel, turned around
        asl
        asl
        tax
        ldy #$06
        lda ($F0),y
        pha
        lda $F2
        sta $FB
        cmp #$01                            ; the triangle
        bne square_noise
        pla
        and #$0F
        ora #$80
        bne triangle_out
; A square, or the noise.
square_noise:
        pla
        ora #$30                            ; the loudness holds at this level
        sta $4000,x                         ; volume and tone
        lda #$10
        ldy #$05
        and ($F0),y
        bne may_restart                     ; leave the slide alone
        lda #$08
        ldy $FB
        sta sweep_off,y
        sta $4001,x                         ; no pitch slide
        jmp send_low
; The triangle sounds when the loudness is not zero.
triangle_out:
        sta $4000,x
; See whether the pitch starts the note over.
may_restart:
        ldy #$08
        lda ($F0),y
        bpl channel_done                    ; already sent
        and #$7F                            ; mark it sent
        sta ($F0),y
; Send the low byte of the pitch.
send_low:
        ldy #$07
        lda ($F0),y
        sta $4002,x                         ; the low pitch byte
        iny
        lda ($F0),y
        ora #$18
        ldy $FB
        beq send_high
        cpy #$01
        beq send_high
        cmp period_hi,y
        beq channel_done                    ; same pitch, so leave it
; Send the high byte. That starts the note over.
send_high:
        sta $4003,x                         ; the high pitch byte. Writing it restarts the note.
        sta period_hi,y                     ; remember it
        lda sweep_off,y
        bne channel_done                    ; not sliding
        lda #$00
        sta period_hi,y                     ; sliding, so start it again next frame
; This channel has been sent.
channel_done:
        rts
; --- $8161  How loud this note is. Then the pitch wobbles.
note_loudness:
        ldy #$05
        lda ($F0),y
        tax
        and #$F0
        sta $F6
        and #$20                            ; a rest
        beq note_heard                      ; the note is heard
        lda #$0F                            ; a rest plays nothing
        sta $F7
        bne mix_loud
; Not a rest, so the note can fade.
note_heard:
        txa
        and #$0F
        sta $F7
        ldy $F3
        dey
        ldx fade_left,y
        beq mix_loud                        ; not fading
        dex
        txa
        sta fade_left,y
        bne mix_loud
        lda $F7
        clc
        adc #$01
        cmp #$0F
        sta $F7
        bne keep_quiet
        lda #$00
        sta fade_load,y                     ; fully quiet, so the fade stops
; Remember how quiet the note has gotten.
keep_quiet:
        lda $F7
        ora $F6
        tax
        ldy #$05
        sta ($F0),y
        txa
        and #$0F
        sta $F7
        ldy $F3
        dey
        ldx fade_left,y
        bne mix_loud
        lda fade_load,y
        sta fade_left,y
; The shape's loudness, minus how quiet this channel is.
mix_loud:
        ldx $F2
        lda loud_level,x
        clc
        sbc $F7                             ; minus how quiet this channel is
        bpl store_loud                      ; still audible
        lda #$00
; That is how loud it plays. The tone stays.
store_loud:
        ora $F6
        ldy #$06
        sta ($F0),y
        ldx $F3
        dex
        lda wobble_on,x
        bne do_wobble                       ; wobble around the note
        rts
; The pitch wobbles around the note.
do_wobble:
        lda $F8
        asl
        tay
        lda pitch_move,y
        sta $F9
        lda pitch_move+1,y
        sta $FA
        jmp ($00F9)

; --- $81E0  How a note's pitch wobbles.
pitch_move:
        .word pitch_note
        .word pitch_up
        .word pitch_higher
        .word pitch_up
        .word pitch_note
        .word pitch_down
        .word pitch_lower
        .word pitch_down
; A little lower than the note.
pitch_down:
        lda #$01
; This much lower than the note.
lower_by:
        clc
        adc pitch_low,x
        ldy #$07
        sta ($F0),y
        lda pitch_high,x
        adc #$00
        iny
        sta ($F0),y
        jmp wobble_step
; Lower than the note.
pitch_lower:
        lda #$02
        jmp lower_by
; The note itself.
pitch_note:
        lda pitch_low,x
        ldy #$07
        sta ($F0),y
        lda pitch_high,x
        iny
        sta ($F0),y
; The next step of the wobble.
wobble_step:
        lda $F8
        clc
        adc #$01
        cmp #$08
        bne wobble_next
        lda #$00
; The next step of the wobble. After eight it starts over.
wobble_next:
        sta $F8
        rts
; A little higher than the note.
pitch_up:
        lda pitch_low,x
        clc
        sbc #$01
; This much higher than the note.
higher_by:
        ldy #$07
        sta ($F0),y
        lda pitch_high,x
        sbc #$00
        iny
        sta ($F0),y
        jmp wobble_step
; Higher than the note.
pitch_higher:
        lda pitch_low,x
        clc
        sbc #$02
        jmp higher_by
; --- $8243  Start the sound in Y.
start_sound:
        stx $F5
        lda #$00
        sta sound,x
        dey
        tya
        asl
        tay
        lda sound_list,y
        sta $F0
        lda sound_list+1,y
        sta $F1
        ldy #$00
; The next track in this sound. $80 or higher ends the list.
next_part:
        lda ($F0),y
        bpl set_track                       ; a track number
        ldx #$0F
        stx $4015                           ; turn the sound channels on
        ldx $F5
        rts
; Point this track at its notes, and clear its wobble and fade.
set_track:
        sta $F4
        lda #$08
        clc
        sbc $F4
        tax
        lda #$00
        sta track_tune,x
        sta wobble_on,x
        sta period_hi+3                     ; forget the squares, so the new notes start
        sta period_hi+2
        sta fade_left,x
        sta fade_load,x
        lda $F4
        asl
        asl
        asl
        asl
        tax
        iny
        lda ($F0),y
        sta track,x
        iny
        lda ($F0),y
        sta track+1,x
        lda #$00
        sta track+5,x                       ; no tone yet, and not quieted
        lda #$0F
        sta track+9,x                       ; a called part returns to the end of this track
        lda $F4
        asl
        asl
        tax
        lda #$01                            ; the notes are read this frame
        sta note_left,x
        lsr
        ldx $F4
; This track is playing.
mark_track:
        rol
        dex
        bpl mark_track
        ora channels
        sta channels
        iny
        bpl next_part
; --- $82B9  Read the next notes.
read_notes:
        lda #$CF                            ; not a rest, and not sliding
        ldy #$05
        and ($F0),y
        sta ($F0),y
        ldy #$00
        lda ($F0),y
        sta $F4
        iny
        lda ($F0),y
        sta $F5
        dey
; The next byte of this track.
read_byte:
        lda ($F4),y
        bpl got_note
        iny
        cmp #$E0
        bcc not_command                     ; below $E0: a length, or a skipped pair
        jsr run_command
        bpl read_byte
; Not a command. $B0 and up skips itself and the next byte.
not_command:
        cmp #$B0
        bcc set_length
        iny
        bne read_byte
; How long the next note lasts.
set_length:
        and #$3F
        tax
        lda note_length,x
        ldx $F2
        sta note_left,x
        sta note_hold,x
        bpl read_byte
; A note. Remember where the track continues.
got_note:
        iny
        pha
        tya
        ldy #$00
        clc
        adc $F4
        sta ($F0),y
        iny
        lda #$00
        adc $F5
        sta ($F0),y
        pla
        ldx #$05
        cpx $F3
        beq noise_note
        ldx #$01
        cpx $F3
        bcc tone_note
; Noise. $10 is a rest.
noise_note:
        cmp #$10                            ; a rest
        beq sound_rest
        sta $F4
        lda #$00
        sta $F5
        beq keep_pitch
; A square or the triangle. $0C in the low digit is a rest.
tone_note:
        tax
        and #$0F
        cmp #$0C                            ; a rest, not a pitch
        bne find_pitch
; A rest. The note is silent.
sound_rest:
        ldy #$05
        lda #$20
        ora ($F0),y
        sta ($F0),y
        bne note_set
; The low digit picks the note.
find_pitch:
        asl
        tay
        lda note_pitch,y
        sta $F4
        lda note_pitch+1,y
        sta $F5
        txa
        and #$F0
        lsr
        lsr
        lsr
        lsr
        tax
        beq keep_pitch
; Once around for each step of the octave.
octave_up:
        lsr $F5                             ; a higher octave
        ror $F4
        dex
        bne octave_up
; Store the pitch, plus how this track is tuned.
keep_pitch:
        lda $F4
        ldx $F3
        dex
        clc
        adc track_tune,x
        ldy #$07
        sta ($F0),y
        sta pitch_low,x
        iny
        lda $F5
        adc #$00
        ora #$80                            ; this pitch still has to be sent
        sta ($F0),y
        sta pitch_high,x
; The note is ready. Its loudness starts over.
note_set:
        ldx $F2
        lda note_hold,x
        sta note_left,x
        lda #$01
        sta loud_left,x
        lda #$00
        ldy #$04
        sta ($F0),y
        rts
; --- $837A  Run one sound command.
run_command:
        and #$1F
        asl
        tax
        lda sound_command,x
        sta $F6
        lda sound_command+1,x
        sta $F7
        jmp ($00F6)

; --- $838B  What each sound command does.
sound_command:
        .word set_loudness
        .word skip_byte
        .word set_tone
        .word set_volume
        .word pitch_slide
        .word tune_channel
        .word skip_byte
        .word skip_byte
        .word sound_jump
        .word sound_call
        .word sound_return
        .word sound_repeat
        .word sound_again
        .word start_wobble
        .word skip_byte
        .word stop_wobble
        .word skip_three
        .word skip_byte
        .word skip_byte
        .word skip_byte
        .word skip_byte
        .word skip_byte
        .word skip_byte
        .word skip_byte
        .word samples_ok
        .word channels_on
        .word drum_if_free
        .word play_sample
        .word skip_byte
        .word skip_byte
        .word fade_speed
        .word silence_channel
; Use this loudness.
set_loudness:
        lda ($F4),y
        iny
        sty $F6
        asl
        tax
        lda loudness,x
        tay
        lda loudness+1,x
        tax
        tya
        ldy #$02
        sta ($F0),y
        iny
        txa
        sta ($F0),y
        ldy $F6
        rts
; How much quieter this channel is. A higher number is quieter.
set_volume:
        lda ($F4),y
        iny
        sty $F6
        sta $F7
        lda #$F0
        ldy #$05
        and ($F0),y
        ora $F7
        sta ($F0),y
        ldy $F6
        rts
; Jump to another part of this sound.
sound_jump:
        lda ($F4),y
        iny
        tax
        lda ($F4),y
        stx $F4
        sta $F5
        ldy #$00
        rts
; Play another part, then come back.
sound_call:
        lda ($F4),y
        iny
        tax
        lda ($F4),y
        iny
        pha
        tya
        pha
        ldy #$09
        lda ($F0),y
        tay
        pla
        clc
        adc $F4
        sta ($F0),y
        dey
        lda #$00
        adc $F5
        sta ($F0),y
        dey
        tya
        ldy #$09
        sta ($F0),y
        stx $F4
        pla
        sta $F5
        ldy #$00
        rts
; Come back.
sound_return:
        ldy #$09
        lda ($F0),y
        tay
        iny
        lda ($F0),y
        iny
        sta $F5
        lda ($F0),y
        sta $F4
        tya
        ldy #$09
        sta ($F0),y
        ldy #$00
        rts
; Repeat the next part this many times.
sound_repeat:
        lda ($F4),y
        iny
        tax
        tya
        pha
        ldy #$09
        lda ($F0),y
        tay
        pla
        clc
        adc $F4
        sta $F4
        sta ($F0),y
        dey
        lda #$00
        adc $F5
        sta $F5
        sta ($F0),y
        dey
        txa
        sta ($F0),y
        dey
        tya
        ldy #$09
        sta ($F0),y
        ldy #$00
        rts
; Do that part again.
sound_again:
        sty $F6
        ldy #$09
        lda ($F0),y
        tay
        iny
        lda ($F0),y
        clc
        sbc #$00
        sta ($F0),y
        beq repeat_done
        iny
        lda ($F0),y
        iny
        sta $F5
        lda ($F0),y
        sta $F4
        ldy #$00
        rts
; The repeats are done.
repeat_done:
        iny
        iny
        tya
        ldy #$09
        sta ($F0),y
        ldy $F6
        rts
; The pitch slides.
pitch_slide:
        sty $F6
        ldy #$05
        lda ($F0),y
        ora #$10
        sta ($F0),y
        ldx $F3
        dex
        txa
        eor #$07
        asl
        asl
        and #$0F
        tax
        ldy $F6
        lda ($F4),y
        sta $4001,x
        iny
        ldx $F3
        dex
        txa
        and #$03
        tax
        lda #$00
        sta sweep_off,x
        rts
; The tone of this channel.
set_tone:
        lda ($F4),y
        iny
        sty $F6
        sta $F7
        ldy #$05
        lda #$3F
        and ($F0),y
        ora $F7
        sta ($F0),y
        ldy $F6
        rts
; --- $84D7  Silence this channel.
silence_channel:
        lda #$7F
        and channels
        sta channels
        ldx $F3
        dex
        txa
        eor #$07
        asl
        asl
        and #$0F
        tax
        lda #$30
        sta $4000,x
        pla
        pla                                 ; stop reading this track
        rts
; Tune this channel. A higher number is a little lower.
tune_channel:
        lda ($F4),y
        iny
        sty $F6
        ldx $F3
        dex
        sta track_tune,x
        ldy $F6
        rts
; The pitch starts to wobble.
start_wobble:
        ldx $F3
        dex
        lda #$01
        sta wobble_on,x
        lda #$00
        sta $F8
        rts
; The pitch holds still.
stop_wobble:
        ldx $F3
        dex
        lda #$00
        sta wobble_on,x
        rts
; A drum sample can play.
samples_ok:
        lda #$00
        sta drum_wait
        rts
; --- $851C  Turn the sound channels on. A drum waits until it is allowed.
channels_on:
        lda #$0F
        sta $4015
        sta drum_wait
        rts
; Play this drum if none is playing.
drum_if_free:
        lda drum_wait
        bne drum_busy
        lda $4015
        and #$10
        beq start_drum                      ; no drum is playing
; A drum is already going, or drums are still waiting.
drum_busy:
        iny
        iny
        iny
        rts
; --- $8535  Play a drum sample.
play_sample:
        lda drum_wait
        bne drum_busy
; Play this drum.
start_drum:
        lda #$0F
        sta $4015
        lda ($F4),y
        sta $4010
        iny
        lda ($F4),y
        sta $4012
        iny
        lda ($F4),y
        sta $4013
        lda #$1F
        sta $4015
        iny
        rts
; How fast the note fades.
fade_speed:
        lda ($F4),y
        iny
        sty $F6
        ldx $F3
        dex
        sta fade_left,x
        sta fade_load,x
        ldy $F6
        rts
; Skip the next byte.
skip_byte:
        iny
        rts
; Skip the next three bytes.
skip_three:
        iny
        iny
        iny
        rts

; --- $856E  How high each note is. The next octave is higher.
note_pitch:
        .word $06AE
        .word $064E
        .word $05F3
        .word $059E
        .word $054D
        .word $0501
        .word $04B9
        .word $0475
        .word $0435
        .word $03F8
        .word $03BF
        .word $0389

; --- $8586  How long a note lasts.
note_length:
        .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0C, $0E, $0F, $10, $12
        .byte $14, $15, $18, $1B, $1C, $1E, $20, $24, $28, $2A, $30, $36, $38, $3C, $40, $48
        .byte $50, $54, $60, $6C, $70, $80, $90, $C0, $FF, $5A, $0D

; --- $85B1  How loud a note is. Two bytes at a time: how many frames, then how loud.
loudness:
        .word fade_down
        .word swell_fade
        .word rise_hold
        .word l8635
        .word fade_waver
        .word l8661
        .word fade_longer
        .word fade_slow
        .word l868D
        .word fade_skip
        .word l86CB
        .word l86CF
        .word l86D3
        .word l86D7
        .word l86DB
        .word waver_down
        .word l86E7
        .word l86A1
        .word fade_uneven
        .word l86DF
        .word l86E3
        .word l86D5
        .word l86EB
; Fades from full to quiet, two frames a step, then stays quiet.
fade_down:
        .byte $02, $0F, $02, $0E, $02, $0D, $02, $0C, $02, $0B, $02, $0A, $02, $09, $02, $08
        .byte $02, $07, $02, $06, $02, $05, $02, $04, $02, $03, $02, $02, $02, $01, $FF, $00
; Rises to full, holds, then fades out.
swell_fade:
        .byte $01, $0B, $01, $0C, $01, $0D, $01, $0E, $0A, $0F, $01, $0E, $01, $0D, $07, $0C
        .byte $08, $0B, $09, $0A, $0A, $09, $0B, $08, $0C, $07, $0D, $06, $0D, $05, $0E, $06
        .byte $0F, $05, $10, $04, $11, $03, $12, $02, $14, $01, $FF, $00
; Rises, stays loud, then goes quiet.
rise_hold:
        .byte $01, $0C, $01, $0D, $01, $0E, $FF, $0F, $FF, $00
; Stays quiet.
l8635:
        .byte $FF, $00
; Fades, then wavers between two levels, then stays quiet.
fade_waver:
        .byte $06, $0F, $07, $0E, $08, $0D, $09, $0C, $0A, $0B, $0B, $0A, $18, $0B, $30, $0A
        .byte $05, $0B, $05, $0A, $06, $0B, $06, $0A, $07, $0B, $07, $0A, $08, $0B, $08, $0A
        .byte $09, $0B, $09, $0A, $0A, $0B, $0A, $0B, $FF, $00
; Stays loud.
l8661:
        .byte $FF, $0F
; Fades out. Each step lasts a little longer.
fade_longer:
        .byte $01, $0F, $02, $0E, $03, $0D, $04, $0C, $05, $0B, $06, $0A, $07, $09, $08, $08
        .byte $09, $07, $0A, $06, $0B, $05, $0C, $04, $0D, $03, $0E, $02, $0F, $01, $FF, $00
; Fades a little, then stays quiet.
fade_slow:
        .byte $0B, $0F, $18, $0E, $24, $0D, $36, $0C, $FF, $00
; Stays quiet.
l868D:
        .byte $FF, $00
; Fades out, two frames a step, skipping every other level.
fade_skip:
        .byte $02, $0F, $02, $0D, $02, $0B, $02, $09, $02, $07, $02, $05, $02, $03, $02, $01
        .byte $FF, $00
; The same fade, one frame a step.
l86A1:
        .byte $01, $0F, $01, $0D, $01, $0B, $01, $09, $01, $07, $01, $05, $01, $03, $01, $01
        .byte $FF, $00
; Fades out. The steps are uneven.
fade_uneven:
        .byte $01, $0F, $02, $0D, $01, $0B, $02, $09, $02, $07, $02, $06, $02, $05, $01, $04
        .byte $01, $03, $01, $02, $01, $01, $FF, $00
; Loud for four frames, then quiet.
l86CB:
        .byte $04, $0F, $FF, $00
; Loud for five frames, then quiet.
l86CF:
        .byte $05, $0F, $FF, $00
; Stays loud.
l86D3:
        .byte $FF, $0F
; Stays quiet.
l86D5:
        .byte $FF, $00
; Loud for eight frames, then quiet.
l86D7:
        .byte $08, $0F, $FF, $00
; Loud for seven frames, then quiet.
l86DB:
        .byte $07, $0F, $FF, $00
; Loud for two frames, then quiet.
l86DF:
        .byte $02, $0F, $FF, $00
; Loud for three frames, then quiet.
l86E3:
        .byte $03, $0F, $FF, $00
; Loud for six frames, then quiet.
l86E7:
        .byte $06, $0F, $FF, $00
; Loud for eleven frames, then quiet.
l86EB:
        .byte $0B, $0F, $FF, $00
; The loudness wavers, and slowly falls.
waver_down:
        .byte $10, $0B, $01, $0C, $01, $0B, $01, $0A, $01, $0B, $01, $0C, $01, $0B, $01, $0A
        .byte $01, $0B, $02, $0C, $02, $0B, $02, $0A, $02, $0B, $02, $0C, $02, $0B, $02, $0C
        .byte $02, $0D, $02, $0C, $02, $0B, $02, $0A, $02, $09, $02, $0A, $02, $0B, $02, $0C
        .byte $02, $0D, $02, $0C, $02, $0B, $02, $0A, $02, $09, $02, $0A, $02, $0B, $02, $0C
        .byte $02, $0D, $02, $0C, $02, $0B, $02, $0A, $02, $09, $02, $0A, $02, $0B, $03, $0C
        .byte $03, $0D, $03, $0C, $03, $0B, $03, $0A, $03, $09, $03, $0A, $03, $0B, $03, $0C
        .byte $03, $0D, $03, $0C, $03, $0B, $03, $0A, $03, $09, $03, $0A, $03, $0B, $04, $0C
        .byte $04, $0D, $04, $0C, $04, $0B, $04, $0A, $04, $09, $04, $0A, $04, $0B, $04, $0C
        .byte $04, $0D, $04, $0C, $04, $0B, $04, $0A, $04, $09, $04, $0A, $FF, $0B

; --- $877D  Which sound each number plays.
sound_list:
        .word sound_01
        .word sound_02                      ; A cutscene ends.
        .word sound_03                      ; Act I, stage 1. Act V, stage 2. Act VI, stage 3.
        .word sound_04                      ; Act II, stage 1. Act VI, stage 1.
        .word sound_05                      ; Act II, stage 2. Act IV, stage 1.
        .word sound_06                      ; Act I, stage 2. Act II, stage 3. Act III, stage 3. Act IV, stage 4. Act VI, stage 4.
        .word sound_07                      ; Act V, stage 1. Act V, stage 4. Act VI, stage 5.
        .word sound_08                      ; The thrown-weapon sound.
        .word sound_08                      ; The thrown-weapon sound.
        .word sound_08                      ; The thrown-weapon sound.
        .word sound_0B                      ; Act III, stage 2. Act VI, stage 2.
        .word sound_0C                      ; Act IV, stage 2.
        .word sound_08                      ; A thrown weapon ends.
        .word sound_0E                      ; Jaquio fires.
        .word snd_jump                      ; He jumps, and when he leaves the air.
        .word sound_10
        .word snd_hurt                      ; Ryu is hurt.
        .word snd_enemy_dies                ; An enemy dies.
        .word snd_pickup                    ; A pickup, or points.
        .word snd_one_up                    ; A 1-UP.
        .word sound_15                      ; Health, or a lantern breaking.
        .word sound_16                      ; While the Invincible Fire-Wheel burns.
        .word snd_star                      ; The Throwing Star.
        .word snd_windmill                  ; The Windmill Throwing Star.
        .word snd_fire_wheel                ; Art of the Fire Wheel.
        .word sound_1A                      ; The spinning sword, the stone man's ring, and the Masked Devil calling fireballs.
        .word snd_beep                      ; The beep while the Hourglass runs, and when time is short.
        .word sound_1C                      ; Bomberhead's sickle, and the last boss's fireballs.
        .word sound_1D
        .word snd_lightning                 ; Bloody Malth calls the lightning.
        .word sound_08                      ; The thrown-weapon sound.
        .word snd_gun                       ; The machine gunner fires.
        .word snd_crouch_shot               ; The crouching soldier fires.
        .word sound_22
        .word snd_lose_life                 ; He loses a life.
        .word snd_start                     ; Start is pressed.
        .word sound_25                      ; Unused. That number fades the sound out instead.
        .word sound_26
        .word sound_27
        .word sound_28
        .word sound_29
        .word sound_2A
        .word sound_2B                      ; Act VI, stage 4.
        .word sound_2C
        .word sound_2D                      ; Act III, stage 1.
        .word sound_2E
        .word sound_2F
        .word sound_30                      ; Act IV, stage 3.
        .word sound_31                      ; Act V, stage 3.
        .word sound_32
        .word sound_33
        .word sound_34
        .word snd_sword                     ; The sword.
        .word sound_36
        .word sound_37
        .word sound_38
        .word sound_39
        .word sound_08                      ; The thrown-weapon sound.
        .word sound_3B
        .word sound_08                      ; The thrown-weapon sound.
        .word sound_3D
        .word sound_3E
        .word snd_hit                       ; An enemy is hit.
        .word snd_boss_explode              ; The boss explodes.
        .word sound_41                      ; Basaquer and Kelbeross.
        .word sound_42
        .word sound_43
        .word sound_08                      ; The thrown-weapon sound.
        .word sound_08                      ; The thrown-weapon sound.
        .word sound_46
        .word sound_47
        .word sound_48
        .word sound_48
        .word sound_4A
        .word sound_4B
        .word sound_4C
        .word sound_4D
        .word sound_4E
        .word sound_02                      ; The cutscene-end sound.
        .word sound_02                      ; The cutscene-end sound.
        .word sound_02                      ; The cutscene-end sound.
        .word sound_02                      ; The cutscene-end sound.
        .word sound_02                      ; The cutscene-end sound.
        .word sound_02                      ; The cutscene-end sound.
        .word sound_02                      ; The cutscene-end sound.
; Unused. That number fades the sound out instead.
sound_25:
        .byte $04, $2A, $88, $FF
; A cutscene ends.
sound_02:
        .byte $00, $43, $88, $01, $43, $88, $02, $43, $88, $03, $43, $88, $04, $43, $88, $05
        .byte $43, $88, $06, $43, $88, $07, $43, $88, $FF
; Act I, stage 1. Act V, stage 2. Act VI, stage 3.
sound_03:
        .byte $04, $54, $88, $05, $58, $89, $02, $6D, $89, $07, $15, $8A, $06, $43, $88, $FF
        .byte $E0, $00, $84, $0C, $E2, $00, $83, $0C, $E3, $0A, $83, $0C, $86, $E9, $27, $89
        .byte $16, $29, $09, $32, $29, $26, $29, $16, $29, $09, $29, $32, $31, $2B, $29, $26
        .byte $E9, $27, $89, $26, $27, $29, $27, $29, $2B, $29, $2B, $31, $2B, $31, $32, $31
        .byte $32, $34, $36, $EB, $03, $E9, $F6, $88, $0A, $2A, $32, $26, $2A, $32, $12, $12
        .byte $11, $27, $31, $23, $27, $31, $13, $13, $EC, $E9, $F6, $88, $0A, $2A, $32, $26
        .byte $2A, $32, $0A, $12, $11, $17, $1A, $21, $27, $2A, $32, $36, $8B, $0C, $26, $86
        .byte $0C, $22, $0C, $26, $22, $0C, $22, $0C, $92, $0C, $8B, $0C, $22, $86, $0C, $8B
        .byte $27, $86, $0C, $27, $22, $0C, $22, $8B, $0C, $86, $24, $29, $8B, $0C, $86, $29
        .byte $8B, $31, $86, $0C, $31, $0C, $31, $29, $0C, $29, $8B, $0C, $86, $31, $0C, $8B
        .byte $0C, $31, $86, $0C, $2A, $0C, $36, $34, $32, $2B, $2A, $27, $26, $24, $21, $E8
        .byte $87, $88, $16, $2B, $29, $26, $29, $2B, $16, $12, $12, $26, $29, $26, $22, $2B
        .byte $32, $2B, $12, $27, $2B, $22, $27, $2B, $12, $0B, $0B, $27, $2B, $27, $12, $2B
        .byte $32, $37, $0B, $29, $31, $24, $29, $31, $0B, $12, $12, $29, $31, $29, $22, $29
        .byte $31, $34, $EA, $0B, $26, $12, $29, $2B, $26, $2B, $0B, $26, $12, $26, $2B, $12
        .byte $10, $0B, $26, $11, $26, $0A, $2A, $31, $26, $31, $11, $26, $0A, $26, $2A, $0A
        .byte $11, $14, $2A, $12, $27, $11, $31, $27, $22, $31, $12, $27, $11, $27, $31, $11
        .byte $12, $14, $31, $EA, $81, $0C, $E0, $04, $84, $0C, $E2, $00, $83, $0C, $E3, $0B
        .byte $82, $0C, $E5, $02, $81, $0C, $E8, $60, $88, $82, $0C, $E0, $0A, $88, $0C, $EB
        .byte $02, $86, $1B, $0C, $1B, $0C, $0C, $0C, $1B, $1B, $0C, $1B, $1B, $1B, $1B, $1B
        .byte $1B, $0C, $21, $0C, $21, $0C, $0C, $0C, $21, $21, $0C, $21, $21, $21, $21, $21
        .byte $21, $0C, $22, $0C, $22, $0C, $0C, $0C, $22, $22, $0C, $22, $22, $22, $22, $22
        .byte $22, $0C, $26, $0C, $26, $0C, $0C, $0C, $26, $26, $0C, $26, $26, $26, $26, $26
        .byte $26, $0C, $EC, $EB, $04, $1B, $1B, $0C, $1B, $1B, $0C, $0C, $0C, $1B, $0C, $0C
        .byte $1B, $0C, $0C, $0C, $0C, $22, $22, $0C, $22, $22, $0C, $0C, $0C, $22, $0C, $0C
        .byte $22, $0C, $0C, $0C, $0C, $19, $19, $0C, $19, $19, $0C, $0C, $0C, $19, $0C, $0C
        .byte $19, $0C, $0C, $0C, $0C, $1A, $1A, $0C, $1A, $1A, $0C, $0C, $0C, $21, $21, $21
        .byte $21, $0C, $21, $21, $21, $EC, $EB, $08, $26, $22, $EC, $EB, $08, $27, $22, $EC
        .byte $EB, $08, $21, $19, $EC, $EB, $06, $21, $1A, $EC, $26, $26, $0C, $26, $E8, $B7
        .byte $89, $83, $10, $E0, $11, $83, $10, $E3, $05, $84, $10, $EB, $07, $FB, $0F, $F0
        .byte $10, $86, $01, $10, $FB, $0F, $F0, $10, $02, $01, $01, $10, $FB, $0F, $F0, $10
        .byte $02, $FB, $0F, $F0, $10, $01, $01, $FB, $0F, $F0, $10, $10, $02, $01, $FB, $0F
        .byte $F0, $10, $01, $FB, $0F, $F0, $10, $10, $FB, $0F, $F0, $10, $02, $01, $EC, $EB
        .byte $03, $EB, $03, $FB, $0F, $F4, $20, $01, $EC, $01, $EC, $EB, $04, $FB, $0F, $F4
        .byte $20, $01, $EC, $EB, $0F, $FB, $0F, $F0, $10, $01, $FB, $0F, $F0, $10, $10, $02
        .byte $01, $FB, $0F, $F4, $20, $01, $10, $FB, $0F, $F0, $10, $02, $FB, $0F, $F0, $10
        .byte $01, $01, $FB, $0F, $F0, $10, $10, $FB, $0F, $F0, $10, $02, $FB, $0F, $F0, $10
        .byte $01, $FB, $0F, $F4, $20, $01, $FB, $0F, $F4, $20, $10, $FB, $0F, $F0, $10, $02
        .byte $FB, $0F, $F0, $10, $01, $EC, $EB, $02, $EB, $02, $FB, $0F, $F4, $20, $01, $EC
        .byte $01, $EC, $EB, $02, $FB, $0F, $F0, $10, $01, $EC, $EB, $08, $FB, $0F, $F4, $20
        .byte $01, $EC, $EB, $03, $FB, $0F, $F0, $10, $01, $10, $02, $01, $FB, $0F, $F4, $20
        .byte $01, $10, $02, $01, $FB, $0F, $F4, $20, $01, $10, $02, $FB, $0F, $F4, $20, $01
        .byte $01, $10, $FB, $0F, $F0, $10, $02, $01, $EC, $FB, $0F, $F0, $10, $01, $10, $02
        .byte $01, $FB, $0F, $F4, $20, $01, $10, $02, $01, $EB, $08, $FB, $0F, $F4, $20, $01
        .byte $EC, $E8, $67, $8A
; Act II, stage 1. Act VI, stage 1.
sound_04:
        .byte $04, $18, $8B, $05, $DA, $8B, $02, $EF, $8B, $07, $9B, $8C, $06, $43, $88, $FF
        .byte $E0, $00, $84, $0C, $E2, $00, $83, $0C, $E3, $09, $0C, $86, $14, $24, $14, $24
        .byte $14, $24, $14, $27, $14, $2B, $14, $30, $14, $32, $14, $34, $EB, $04, $09, $0C
        .byte $09, $0C, $8B, $19, $86, $09, $8B, $20, $86, $09, $8B, $24, $86, $09, $20, $1B
        .byte $24, $10, $0C, $10, $0C, $8B, $20, $86, $10, $8B, $23, $86, $10, $8B, $27, $86
        .byte $10, $23, $23, $20, $12, $0C, $12, $0C, $8B, $22, $86, $12, $8B, $26, $86, $12
        .byte $8B, $29, $86, $26, $24, $23, $22, $24, $20, $19, $20, $0C, $0C, $0C, $0C, $0C
        .byte $0C, $20, $1B, $19, $20, $0C, $0C, $EC, $E9, $A9, $8B, $20, $10, $24, $10, $25
        .byte $10, $27, $10, $1B, $0B, $22, $0B, $24, $0B, $25, $0B, $E9, $A9, $8B, $15, $25
        .byte $29, $30, $32, $30, $2B, $29, $14, $24, $27, $29, $30, $32, $34, $32, $E8, $34
        .byte $8B, $24, $14, $27, $14, $2B, $14, $30, $14, $32, $14, $30, $14, $2B, $14, $29
        .byte $14, $27, $17, $29, $17, $30, $17, $32, $17, $34, $17, $35, $17, $34, $17, $32
        .byte $17, $29, $19, $2B, $19, $30, $19, $32, $19, $34, $19, $35, $19, $37, $19, $35
        .byte $19, $EA, $81, $0C, $E0, $04, $84, $0C, $E2, $00, $83, $0C, $E3, $0B, $82, $0C
        .byte $E5, $02, $81, $0C, $E8, $23, $8B, $82, $0C, $E0, $0A, $88, $0C, $86, $25, $25
        .byte $0C, $25, $25, $25, $0C, $25, $27, $25, $24, $25, $20, $1B, $19, $1B, $EB, $04
        .byte $19, $19, $0C, $19, $0C, $19, $19, $19, $0C, $19, $19, $0C, $0C, $19, $19, $19
        .byte $20, $20, $0C, $20, $0C, $20, $20, $20, $0C, $20, $20, $0C, $0C, $20, $20, $20
        .byte $22, $22, $0C, $22, $0C, $22, $22, $22, $19, $19, $0C, $19, $0C, $19, $19, $19
        .byte $0C, $19, $19, $0C, $0C, $19, $19, $19, $EC, $E9, $6A, $8C, $20, $20, $0C, $20
        .byte $20, $20, $0C, $20, $1B, $1B, $0C, $1B, $1B, $1B, $0C, $1B, $E9, $6A, $8C, $25
        .byte $25, $0C, $25, $25, $25, $0C, $25, $24, $24, $0C, $24, $24, $24, $0C, $24, $E8
        .byte $06, $8C, $24, $24, $0C, $24, $24, $24, $0C, $24, $24, $24, $0C, $24, $24, $24
        .byte $0C, $24, $20, $20, $0C, $20, $20, $20, $0C, $20, $20, $20, $0C, $20, $20, $20
        .byte $0C, $20, $22, $22, $0C, $22, $22, $22, $0C, $22, $22, $22, $0C, $22, $22, $22
        .byte $0C, $22, $EA, $83, $10, $E0, $11, $10, $E3, $05, $84, $10, $FB, $0F, $F4, $20
        .byte $86, $10, $10, $EB, $02, $FB, $0F, $F4, $20, $10, $EC, $10, $10, $10, $10, $10
        .byte $EB, $02, $FB, $0F, $F4, $20, $10, $EC, $10, $EB, $04, $FB, $0F, $F4, $20, $10
        .byte $EC, $EB, $0F, $EB, $02, $FB, $0F, $F0, $10, $10, $EC, $02, $FB, $0F, $F0, $10
        .byte $01, $FB, $0F, $F4, $20, $10, $FB, $0F, $F0, $10, $10, $FB, $0F, $F0, $10, $02
        .byte $FB, $0F, $F0, $10, $01, $01, $EB, $02, $FB, $0F, $F0, $10, $10, $EC, $02, $FB
        .byte $0F, $F4, $20, $10, $01, $FB, $0F, $F0, $10, $01, $FB, $0F, $F0, $10, $02, $EC
        .byte $EB, $04, $FB, $0F, $F4, $20, $10, $EC, $10, $FB, $0F, $F0, $10, $10, $EB, $02
        .byte $FB, $0F, $F4, $20, $10, $EC, $10, $FB, $0F, $F0, $10, $10, $EB, $04, $FB, $0F
        .byte $F4, $20, $10, $EC, $EB, $02, $FB, $0F, $F0, $10, $10, $EC, $EB, $03, $EB, $02
        .byte $FB, $0F, $F0, $10, $10, $10, $02, $01, $EC, $FB, $0F, $F0, $10, $01, $10, $10
        .byte $02, $FB, $0F, $F0, $10, $10, $FB, $0F, $F0, $10, $01, $FB, $0F, $F4, $20, $01
        .byte $FB, $0F, $F4, $20, $02, $EB, $02, $FB, $0F, $F0, $10, $10, $10, $02, $01, $EC
        .byte $FB, $0F, $F0, $10, $01, $10, $10, $02, $EB, $02, $FB, $0F, $F4, $20, $10, $EC
        .byte $10, $FB, $0F, $F4, $20, $10, $EC, $EB, $02, $FB, $0F, $F0, $10, $10, $10, $02
        .byte $01, $EC, $FB, $0F, $F0, $10, $01, $10, $10, $02, $FB, $0F, $F0, $10, $10, $FB
        .byte $0F, $F0, $10, $01, $FB, $0F, $F4, $20, $01, $FB, $0F, $F4, $20, $02, $FB, $0F
        .byte $F0, $10, $10, $10, $EB, $03, $FB, $0F, $F4, $20, $10, $EC, $10, $FB, $0F, $F4
        .byte $20, $10, $10, $FB, $0F, $F0, $10, $10, $EB, $07, $FB, $0F, $F4, $20, $10, $EC
        .byte $E8, $C9, $8C
; Act II, stage 2. Act IV, stage 1.
sound_05:
        .byte $04, $DB, $8D, $05, $93, $8E, $02, $0C, $8F, $07, $15, $8F, $06, $39, $8F, $FF
        .byte $E0, $04, $84, $0C, $E2, $C0, $83, $0C, $E3, $0A, $0C, $ED, $A2, $0C, $0C, $0C
        .byte $9A, $0C, $86, $24, $26, $28, $2A, $28, $2A, $2B, $31, $E3, $09, $A2, $31, $2B
        .byte $2A, $9A, $28, $E3, $0A, $86, $34, $33, $31, $2B, $31, $2B, $2A, $2B, $E3, $09
        .byte $A2, $31, $2B, $2A, $9A, $28, $E3, $0A, $86, $24, $26, $28, $2A, $28, $2A, $2B
        .byte $31, $E3, $09, $A2, $2B, $2A, $26, $9A, $28, $E3, $0A, $86, $34, $33, $31, $2B
        .byte $31, $2B, $2A, $2B, $E3, $09, $A2, $2B, $33, $34, $9A, $38, $E3, $0A, $86, $24
        .byte $26, $28, $2A, $28, $2A, $2B, $31, $E2, $80, $E0, $00, $E3, $0A, $EF, $86, $31
        .byte $31, $31, $0C, $36, $0C, $31, $0C, $36, $0C, $31, $0C, $36, $31, $34, $31, $31
        .byte $31, $31, $0C, $38, $0C, $31, $0C, $38, $0C, $31, $0C, $38, $31, $34, $31, $31
        .byte $31, $31, $0C, $36, $0C, $31, $0C, $36, $0C, $31, $0C, $36, $31, $34, $36, $31
        .byte $31, $31, $0C, $38, $0C, $31, $0C, $38, $0C, $31, $0C, $38, $31, $2B, $31, $E0
        .byte $04, $E2, $C0, $E3, $0A, $E8, $E6, $8D, $81, $0C, $E0, $06, $84, $0C, $E2, $C0
        .byte $83, $0C, $E3, $0A, $82, $0C, $EB, $0B, $86, $21, $21, $21, $21, $0C, $21, $0C
        .byte $21, $0C, $21, $21, $21, $0C, $21, $0C, $21, $24, $24, $24, $24, $0C, $24, $0C
        .byte $24, $0C, $24, $24, $24, $0C, $24, $0C, $24, $26, $26, $26, $26, $0C, $26, $0C
        .byte $26, $0C, $26, $26, $26, $0C, $26, $0C, $26, $28, $28, $28, $28, $0C, $28, $0C
        .byte $28, $28, $28, $28, $28, $0C, $1B, $1B, $1B, $EC, $E3, $07, $8B, $18, $0C, $0C
        .byte $0C, $0C, $0C, $18, $16, $0C, $0C, $0C, $0C, $0C, $0C, $14, $18, $16, $0C, $0C
        .byte $0C, $0C, $0C, $0C, $13, $14, $0C, $0C, $0C, $14, $97, $18, $E3, $0A, $E8, $A1
        .byte $8E, $82, $0C, $E0, $0B, $88, $0C, $E8, $A1, $8E, $83, $10, $E0, $11, $10, $E3
        .byte $04, $84, $10, $86, $EB, $04, $10, $10, $01, $01, $EC, $10, $01, $10, $01, $10
        .byte $10, $01, $01, $10, $10, $01, $01, $01, $01, $01, $01, $E8, $1E, $8F, $8A, $0C
        .byte $EB, $02, $FB, $0F, $F0, $10, $86, $0C, $EC, $0C, $FB, $0F, $F0, $10, $0C, $FB
        .byte $0F, $F4, $20, $0C, $EB, $03, $FA, $0F, $F0, $10, $0C, $EC, $0C, $EB, $03, $FB
        .byte $0F, $F0, $10, $0C, $EC, $FB, $0F, $F4, $20, $0C, $FA, $0F, $F0, $10, $0C, $0C
        .byte $FA, $0F, $F0, $10, $0C, $E8, $3B, $8F
; A thrown weapon ends.
sound_08:
        .byte $01, $79, $8F, $03, $79, $8F, $FF
; Act I, stage 2. Act II, stage 3. Act III, stage 3. Act IV, stage 4. Act VI, stage 4.
sound_06:
        .byte $04, $BD, $8F, $05, $8A, $8F, $02, $63, $90, $07, $6C, $90, $06, $9D, $90, $FF
        .byte $E0, $05, $84, $0C, $E2, $C0, $83, $0C, $E3, $0C, $83, $0C, $ED, $8C, $22, $32
        .byte $23, $33, $24, $34, $87, $26, $36, $26, $36, $EB, $02, $A4, $19, $17, $19, $17
        .byte $9C, $15, $14, $15, $14, $94, $13, $14, $15, $14, $EC, $A4, $0C, $0C, $0C, $0C
        .byte $E8, $A3, $8F, $81, $0C, $E0, $00, $84, $0C, $E2, $80, $83, $0C, $E3, $09, $82
        .byte $0C, $8C, $12, $22, $13, $23, $14, $24, $87, $16, $26, $16, $26, $EB, $02, $EB
        .byte $02, $87, $19, $19, $19, $19, $20, $1B, $1A, $19, $19, $19, $19, $19, $20, $1B
        .byte $1A, $19, $17, $18, $17, $18, $1A, $19, $18, $17, $17, $18, $17, $18, $1A, $19
        .byte $18, $17, $EC, $15, $15, $14, $14, $18, $18, $17, $17, $21, $21, $1A, $1A, $17
        .byte $17, $14, $14, $15, $15, $18, $18, $17, $21, $20, $15, $14, $15, $17, $18, $1A
        .byte $20, $21, $20, $1B, $1B, $1B, $1B, $18, $18, $18, $18, $15, $15, $15, $15, $14
        .byte $14, $1B, $1B, $EC, $EB, $02, $19, $19, $18, $18, $17, $17, $16, $16, $15, $15
        .byte $16, $16, $17, $17, $18, $18, $EC, $21, $21, $20, $20, $1B, $1B, $18, $18, $17
        .byte $17, $18, $18, $1B, $1B, $20, $20, $21, $21, $20, $20, $1B, $1B, $20, $20, $21
        .byte $21, $20, $20, $8C, $1A, $17, $E8, $D7, $8F, $82, $0C, $E0, $0B, $88, $0C, $E8
        .byte $CB, $8F, $83, $10, $E0, $11, $83, $10, $E3, $05, $84, $10, $A4, $10, $EB, $07
        .byte $EB, $02, $8C, $02, $87, $01, $01, $01, $01, $01, $01, $EC, $EB, $02, $87, $01
        .byte $01, $01, $01, $8C, $02, $87, $01, $01, $EC, $EC, $EB, $10, $8C, $10, $02, $EC
        .byte $E8, $78, $90, $8A, $0C, $EB, $03, $FB, $0F, $F4, $20, $94, $0C, $EC, $EB, $04
        .byte $FB, $0F, $F4, $20, $87, $0C, $EC, $EB, $02, $FB, $0F, $F0, $10, $94, $0C, $FB
        .byte $0F, $F4, $20, $8C, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C
        .byte $FB, $0F, $F4, $20, $0C, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20
        .byte $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20
        .byte $0C, $EB, $02, $FB, $0F, $F4, $20, $87, $0C, $EC, $FB, $0F, $F0, $10, $8C, $0C
        .byte $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10
        .byte $0C, $FB, $0F, $F4, $20, $0C, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4
        .byte $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $EB, $04, $FB
        .byte $0F, $F4, $20, $87, $0C, $EC, $FB, $0F, $F0, $10, $8C, $0C, $0C, $FB, $0F, $F4
        .byte $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4
        .byte $20, $0C, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F
        .byte $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $EB, $02
        .byte $FB, $0F, $F4, $20, $87, $0C, $EC, $FB, $0F, $F0, $10, $8C, $0C, $0C, $FB, $0F
        .byte $F4, $20, $0C, $0C, $FB, $0F, $F4, $20, $87, $0C, $FB, $0F, $F4, $20, $0C, $0C
        .byte $EB, $05, $FB, $0F, $F4, $20, $0C, $EC, $EC, $EB, $03, $FB, $0F, $F0, $10, $94
        .byte $0C, $EC, $FB, $0F, $F4, $20, $87, $0C, $FB, $0F, $F4, $20, $0C, $0C, $FB, $0F
        .byte $F4, $20, $0C, $EB, $03, $FB, $0F, $F0, $10, $94, $0C, $EC, $EB, $04, $FB, $0F
        .byte $F4, $20, $87, $0C, $EC, $EB, $03, $FB, $0F, $F0, $10, $94, $0C, $EC, $FB, $0F
        .byte $F4, $20, $87, $0C, $0C, $EB, $02, $FB, $0F, $F4, $20, $0C, $EC, $EB, $02, $EB
        .byte $02, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F4, $20, $0C, $0C, $EC, $EB, $02, $FB
        .byte $0F, $F4, $20, $0C, $EC, $EC, $E8, $B1, $90
; Act V, stage 1. Act V, stage 4. Act VI, stage 5.
sound_07:
        .byte $04, $03, $92, $05, $AA, $92, $02, $0E, $93, $07, $61, $93, $06, $A8, $93, $FF
        .byte $E0, $06, $84, $0C, $E2, $40, $83, $0C, $E3, $09, $0C, $ED, $8B, $1A, $1A, $1A
        .byte $20, $20, $20, $20, $20, $21, $21, $21, $23, $23, $23, $23, $23, $EB, $02, $86
        .byte $2A, $2A, $2A, $2A, $EF, $8B, $29, $ED, $E0, $04, $E3, $0A, $92, $2A, $E0, $06
        .byte $E3, $09, $8B, $EF, $29, $2A, $29, $ED, $86, $28, $28, $28, $28, $8B, $27, $E0
        .byte $04, $E3, $0A, $92, $28, $E0, $06, $E3, $09, $8B, $27, $28, $27, $EC, $E0, $00
        .byte $E2, $00, $E3, $09, $EB, $02, $86, $26, $25, $24, $26, $25, $24, $28, $25, $24
        .byte $26, $25, $24, $28, $25, $24, $26, $24, $23, $21, $24, $23, $21, $26, $23, $21
        .byte $24, $23, $21, $26, $23, $21, $23, $EC, $21, $20, $8B, $1B, $86, $20, $21, $23
        .byte $25, $26, $28, $E3, $08, $8B, $EF, $29, $ED, $2A, $30, $E0, $06, $E2, $40, $E3
        .byte $09, $EB, $03, $1A, $1A, $1A, $20, $20, $20, $20, $20, $21, $21, $21, $23, $23
        .byte $23, $23, $23, $EC, $E8, $20, $92, $81, $0C, $E0, $06, $84, $0C, $E2, $80, $83
        .byte $0C, $E3, $09, $82, $0C, $8B, $EB, $10, $1A, $EC, $EB, $02, $86, $23, $23, $23
        .byte $23, $8B, $23, $E0, $04, $E3, $0A, $92, $23, $E0, $06, $E3, $09, $8B, $23, $23
        .byte $23, $86, $21, $21, $21, $21, $8B, $21, $E0, $04, $E3, $0A, $92, $21, $E0, $06
        .byte $E3, $09, $8B, $21, $21, $21, $EC, $E0, $09, $E2, $C0, $E3, $0A, $EB, $02, $86
        .byte $EB, $10, $18, $EC, $EB, $10, $16, $EC, $EC, $EB, $10, $15, $EC, $E0, $06, $E2
        .byte $80, $E3, $09, $8B, $EB, $30, $1A, $EC, $E8, $BD, $92, $82, $0C, $E0, $0B, $88
        .byte $0C, $EB, $10, $8B, $1A, $EC, $EB, $02, $86, $20, $20, $20, $20, $8B, $20, $92
        .byte $20, $8B, $20, $20, $20, $86, $1A, $1A, $1A, $1A, $8B, $1A, $92, $1A, $8B, $1A
        .byte $1A, $1A, $EC, $EB, $02, $18, $28, $18, $28, $18, $28, $18, $28, $16, $26, $16
        .byte $26, $16, $26, $16, $26, $EC, $15, $25, $15, $25, $15, $25, $15, $25, $EB, $10
        .byte $8B, $1A, $EC, $EB, $10, $18, $EC, $EB, $10, $26, $EC, $E8, $19, $93, $83, $10
        .byte $E0, $11, $10, $E3, $05, $84, $10, $EB, $08, $92, $01, $EC, $EB, $04, $86, $01
        .byte $01, $01, $01, $8B, $01, $92, $01, $8B, $01, $01, $01, $EC, $EB, $02, $8B, $01
        .byte $01, $02, $01, $01, $01, $01, $E0, $09, $92, $02, $E0, $11, $8B, $01, $01, $01
        .byte $01, $01, $02, $01, $EC, $01, $01, $02, $01, $01, $01, $02, $01, $EB, $10, $92
        .byte $01, $EC, $E8, $6A, $93, $8A, $0C, $EB, $07, $FB, $0F, $F0, $10, $92, $0C, $EC
        .byte $EB, $04, $FB, $0F, $F4, $20, $86, $0C, $EC, $EB, $04, $EB, $02, $FB, $0F, $F0
        .byte $10, $8B, $0C, $EC, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $EB
        .byte $02, $FB, $0F, $F4, $20, $0C, $EC, $EB, $02, $FB, $0F, $F4, $20, $86, $0C, $EC
        .byte $EC, $EB, $02, $FB, $0F, $F0, $10, $8B, $0C, $0C, $FB, $0F, $F4, $20, $0C, $FB
        .byte $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $0C
        .byte $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C
        .byte $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $EB, $02, $FB, $0F, $F4
        .byte $20, $86, $0C, $EC, $EC, $FB, $0F, $F0, $10, $92, $0C, $FB, $0F, $F4, $20, $0C
        .byte $FB, $0F, $F4, $20, $86, $0C, $FB, $0F, $F4, $20, $8B, $0C, $EB, $05, $FB, $0F
        .byte $F4, $20, $86, $0C, $EC, $EB, $07, $FB, $0F, $F0, $10, $92, $0C, $EC, $FB, $0F
        .byte $F4, $20, $8B, $0C, $EB, $02, $FB, $0F, $F4, $20, $86, $0C, $EC, $EB, $07, $FB
        .byte $0F, $F0, $10, $92, $0C, $EC, $EB, $04, $FB, $0F, $F4, $20, $86, $0C, $EC, $EB
        .byte $06, $FB, $0F, $F0, $10, $92, $0C, $EC, $FB, $0F, $F4, $20, $86, $0C, $FB, $0F
        .byte $F4, $20, $8B, $0C, $EB, $05, $FB, $0F, $F4, $20, $86, $0C, $EC, $E8, $BC, $93
        .byte $FF
; Act III, stage 2. Act VI, stage 2.
sound_0B:
        .byte $04, $A4, $94, $05, $A7, $95, $02, $9A, $95, $07, $34, $96, $06, $4F, $96, $FF
        .byte $E0, $04, $84, $0C, $E2, $C0, $83, $0C, $E3, $0B, $0C, $ED, $8A, $24, $34, $32
        .byte $22, $21, $31, $30, $20, $EB, $02, $EB, $04, $8A, $2B, $EF, $29, $ED, $EC, $EB
        .byte $04, $30, $2B, $EC, $EB, $04, $2B, $EF, $29, $ED, $EC, $EB, $04, $30, $2B, $EC
        .byte $EB, $04, $2A, $EF, $29, $ED, $EC, $EB, $04, $30, $2B, $EC, $EB, $04, $2A, $EF
        .byte $29, $ED, $EC, $EB, $04, $30, $2B, $EC, $EC, $E9, $2E, $95, $E0, $00, $EB, $02
        .byte $EB, $08, $85, $2B, $EF, $29, $ED, $EC, $EB, $08, $30, $2B, $EC, $EB, $08, $2B
        .byte $EF, $29, $ED, $EC, $EB, $08, $30, $2B, $EC, $EB, $08, $2A, $EF, $29, $ED, $EC
        .byte $EB, $08, $30, $2B, $EC, $EB, $08, $2A, $EF, $29, $ED, $EC, $EB, $08, $30, $2B
        .byte $EC, $EC, $E0, $04, $E9, $2E, $95, $E8, $B9, $94, $8A, $32, $32, $98, $0C, $8A
        .byte $28, $E3, $09, $9A, $31, $E3, $0A, $82, $0C, $85, $31, $2B, $2A, $EF, $29, $27
        .byte $29, $ED, $2B, $31, $8A, $30, $30, $98, $0C, $8A, $30, $E3, $09, $9A, $2A, $E3
        .byte $0A, $82, $0C, $85, $30, $2A, $EF, $29, $2A, $29, $ED, $2A, $30, $32, $8A, $32
        .byte $32, $98, $0C, $8A, $2A, $E3, $09, $9A, $31, $E3, $0A, $82, $0C, $85, $31, $2B
        .byte $2A, $EF, $29, $27, $29, $ED, $2B, $31, $8A, $25, $25, $98, $0C, $8A, $25, $27
        .byte $85, $EF, $29, $ED, $27, $25, $0C, $27, $25, $24, $0C, $25, $24, $22, $0C, $24
        .byte $25, $27, $EF, $29, $ED, $EA, $82, $0C, $E0, $0C, $88, $0C, $A0, $19, $E0, $0B
        .byte $E8, $BB, $95, $81, $0C, $E0, $05, $84, $0C, $E2, $C0, $83, $0C, $E3, $0C, $82
        .byte $0C, $A0, $19, $E0, $04, $E3, $0A, $E9, $08, $96, $E9, $08, $96, $E9, $C7, $95
        .byte $E8, $BB, $95, $8A, $25, $25, $98, $0C, $8A, $28, $9E, $21, $86, $0C, $90, $0C
        .byte $8A, $24, $24, $98, $0C, $8A, $20, $9E, $1A, $86, $0C, $90, $0C, $8A, $24, $24
        .byte $98, $0C, $8A, $28, $9E, $21, $86, $0C, $90, $0C, $8A, $19, $19, $98, $0C, $8A
        .byte $21, $20, $85, $22, $22, $0C, $22, $20, $0C, $20, $20, $1B, $0C, $1B, $1B, $19
        .byte $0C, $19, $19, $EA, $EB, $02, $8A, $19, $24, $0C, $90, $25, $8A, $24, $20, $0C
        .byte $19, $26, $0C, $90, $27, $8A, $26, $22, $0C, $EC, $EB, $02, $17, $22, $0C, $90
        .byte $23, $8A, $22, $1A, $0C, $17, $24, $0C, $90, $25, $8A, $24, $20, $0C, $EC, $EA
        .byte $83, $10, $E0, $11, $10, $E3, $04, $84, $10, $A0, $10, $8A, $01, $01, $02, $10
        .byte $01, $01, $01, $E0, $09, $01, $E0, $11, $E8, $3F, $96, $8A, $0C, $FB, $0F, $F4
        .byte $20, $98, $0C, $FB, $0F, $F4, $20, $90, $0C, $EB, $04, $FB, $0F, $F4, $20, $85
        .byte $0C, $EC, $EB, $10, $EB, $02, $FB, $0F, $F0, $10, $8A, $0C, $EC, $FB, $0F, $F4
        .byte $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F
        .byte $F0, $10, $0C, $EC, $EB, $03, $EB, $02, $FB, $0F, $F0, $10, $8A, $0C, $EC, $98
        .byte $0C, $EB, $02, $FB, $0F, $F4, $20, $8A, $0C, $EC, $98, $0C, $EB, $02, $FB, $0F
        .byte $F4, $20, $8A, $0C, $EC, $EB, $04, $FB, $0F, $F4, $20, $85, $0C, $EC, $EC, $EB
        .byte $02, $FB, $0F, $F0, $10, $8A, $0C, $EC, $98, $0C, $EB, $02, $FB, $0F, $F4, $20
        .byte $8A, $0C, $EC, $98, $0C, $EB, $08, $FB, $0F, $F4, $20, $85, $0C, $EC, $E8, $66
        .byte $96
; Act IV, stage 2.
sound_0C:
        .byte $04, $E5, $96, $05, $E2, $97, $02, $6C, $98, $07, $D9, $98, $06, $3A, $99, $FF
        .byte $E0, $04, $84, $0C, $E2, $40, $83, $0C, $E3, $0A, $0C, $ED, $A2, $0C, $E9, $FC
        .byte $96, $E9, $49, $97, $E8, $F3, $96, $EB, $02, $8B, $26, $EF, $29, $ED, $26, $2B
        .byte $86, $24, $8B, $26, $86, $24, $8B, $26, $86, $31, $31, $26, $26, $26, $26, $8B
        .byte $26, $28, $EF, $29, $ED, $28, $92, $26, $8B, $28, $26, $2B, $28, $86, $26, $8B
        .byte $28, $86, $26, $8B, $28, $86, $31, $31, $28, $28, $28, $28, $8B, $28, $EF, $29
        .byte $2B, $29, $ED, $92, $28, $EC, $92, $26, $24, $22, $21, $8B, $0C, $21, $21, $92
        .byte $21, $8B, $21, $EA, $8B, $26, $28, $E9, $BF, $97, $9A, $31, $8B, $0C, $21, $26
        .byte $28, $E9, $BF, $97, $9A, $31, $8B, $0C, $86, $21, $24, $26, $28, $EF, $29, $ED
        .byte $2B, $EB, $02, $8B, $EF, $29, $ED, $86, $28, $8B, $EF, $29, $ED, $86, $26, $8B
        .byte $EF, $29, $ED, $86, $28, $8B, $EF, $29, $ED, $86, $26, $2B, $EF, $29, $28, $29
        .byte $8B, $29, $86, $28, $8B, $29, $86, $26, $8B, $29, $86, $28, $8B, $29, $86, $26
        .byte $2B, $29, $28, $26, $8B, $2B, $86, $29, $8B, $2B, $86, $28, $8B, $2B, $86, $29
        .byte $8B, $2B, $86, $28, $31, $2B, $29, $28, $ED, $26, $24, $21, $22, $26, $21, $24
        .byte $26, $29, $28, $26, $24, $8B, $31, $2B, $EC, $EA, $8B, $EF, $29, $28, $29, $ED
        .byte $92, $26, $8B, $31, $2B, $EF, $29, $2B, $29, $ED, $2B, $92, $26, $8B, $EF, $29
        .byte $ED, $28, $26, $24, $26, $28, $92, $34, $8B, $32, $31, $2B, $EA, $81, $0C, $E0
        .byte $00, $84, $0C, $E2, $00, $83, $0C, $E3, $09, $82, $0C, $A2, $0C, $E9, $06, $98
        .byte $8B, $0C, $0C, $EB, $04, $E9, $32, $98, $8B, $29, $28, $26, $0C, $EC, $E8, $F2
        .byte $97, $E9, $32, $98, $8B, $26, $26, $25, $0C, $E9, $32, $98, $8B, $26, $26, $25
        .byte $0C, $8B, $11, $86, $26, $21, $8B, $14, $86, $24, $1B, $8B, $12, $86, $22, $19
        .byte $8B, $11, $86, $11, $18, $8B, $11, $11, $11, $11, $11, $0C, $EA, $8B, $16, $86
        .byte $26, $21, $0C, $21, $8B, $26, $86, $16, $26, $8B, $21, $26, $21, $8B, $12, $86
        .byte $26, $22, $0C, $22, $8B, $26, $86, $12, $26, $8B, $22, $26, $22, $8B, $14, $86
        .byte $26, $24, $0C, $24, $8B, $26, $86, $14, $26, $8B, $24, $26, $24, $8B, $11, $86
        .byte $26, $21, $26, $0C, $26, $26, $EA, $82, $0C, $E0, $10, $88, $0C, $EB, $04, $8B
        .byte $11, $21, $EC, $E9, $81, $98, $E9, $B3, $98, $E8, $78, $98, $EB, $02, $16, $26
        .byte $16, $26, $16, $26, $16, $26, $12, $22, $12, $22, $12, $22, $12, $22, $14, $24
        .byte $14, $24, $14, $24, $14, $24, $11, $21, $11, $21, $11, $21, $14, $15, $EC, $16
        .byte $26, $14, $24, $12, $22, $11, $21, $11, $11, $11, $11, $11, $0C, $EA, $0C, $0C
        .byte $EB, $04, $16, $26, $16, $26, $16, $26, $16, $26, $12, $22, $12, $22, $12, $22
        .byte $12, $22, $14, $24, $14, $24, $14, $24, $14, $24, $11, $21, $11, $21, $11, $21
        .byte $14, $15, $EC, $EA, $83, $10, $E0, $11, $10, $E3, $05, $84, $10, $EB, $02, $8B
        .byte $01, $86, $01, $01, $01, $01, $01, $01, $EC, $E9, $F7, $98, $E9, $28, $99, $E8
        .byte $EE, $98, $EB, $04, $8B, $01, $86, $01, $01, $01, $01, $01, $01, $8B, $01, $86
        .byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $10, $01, $01, $8B, $01
        .byte $86, $01, $01, $01, $01, $01, $01, $EC, $EB, $04, $8B, $01, $86, $01, $01, $EC
        .byte $9F, $10, $EA, $8B, $01, $86, $01, $01, $EB, $20, $8B, $01, $86, $01, $01, $01
        .byte $01, $01, $01, $EC, $EA, $8A, $0C, $EB, $02, $FB, $0F, $F0, $10, $92, $0C, $FB
        .byte $0F, $F4, $20, $0C, $EC, $E9, $62, $99, $E9, $62, $99, $E9, $8B, $99, $E9, $B2
        .byte $99, $E9, $B2, $99, $E9, $B2, $99, $E9, $B2, $99, $E8, $4A, $99, $EB, $07, $FB
        .byte $0F, $F0, $10, $92, $0C, $FB, $0F, $F4, $20, $0C, $EC, $FB, $0F, $F4, $20, $86
        .byte $0C, $FB, $0F, $F4, $20, $8B, $0C, $FB, $0F, $F4, $20, $86, $0C, $EB, $04, $FB
        .byte $0F, $F4, $20, $0C, $EC, $EA, $EB, $02, $FB, $0F, $F0, $10, $92, $0C, $FB, $0F
        .byte $F4, $20, $0C, $EC, $EB, $05, $FB, $0F, $F4, $20, $8B, $0C, $EC, $0C, $FB, $0F
        .byte $F4, $20, $0C, $EB, $02, $FB, $0F, $F4, $20, $86, $0C, $EC, $EA, $EB, $07, $FB
        .byte $0F, $F0, $10, $92, $0C, $FB, $0F, $F4, $20, $0C, $EC, $FB, $0F, $F4, $20, $8B
        .byte $0C, $EB, $06, $FB, $0F, $F4, $20, $86, $0C, $EC, $EA
sound_32:
        .byte $04, $E0, $99, $05, $19, $9A, $02, $43, $88, $07, $43, $88, $06, $77, $9A, $FF
        .byte $E0, $04, $E2, $40, $E3, $0A, $EB, $08, $92, $30, $2B, $25, $E0, $05, $97, $24
        .byte $ED, $24, $E0, $04, $92, $24, $0C, $EF, $92, $2A, $29, $25, $E0, $05, $97, $22
        .byte $ED, $22, $E0, $04, $92, $22, $0C, $EF, $EC, $92, $24, $25, $24, $22, $E0, $05
        .byte $97, $24, $ED, $24, $E0, $04, $92, $24, $FF, $E2, $80, $E3, $0B, $EB, $03, $E0
        .byte $05, $A2, $19, $9A, $19, $E0, $04, $19, $E0, $05, $A2, $17, $9A, $17, $E0, $04
        .byte $17, $EC, $E0, $06, $E3, $06, $EB, $02, $92, $09, $19, $0C, $0C, $0C, $0B, $8B
        .byte $10, $92, $12, $8B, $0C, $92, $07, $17, $0C, $15, $0C, $14, $0C, $12, $EC, $EB
        .byte $03, $8B, $09, $09, $92, $0C, $0C, $09, $0C, $09, $8B, $09, $92, $09, $8B, $08
        .byte $8B, $07, $07, $92, $0C, $0C, $07, $0C, $07, $8B, $07, $92, $07, $8B, $08, $EC
        .byte $E0, $04, $9A, $10, $0B, $09, $FF, $E0, $0C, $EB, $28, $FB, $0F, $F0, $10, $9A
        .byte $0C, $EC, $EB, $06, $EB, $02, $FB, $0F, $F0, $10, $8B, $0C, $EC, $9A, $0C, $FB
        .byte $0F, $F0, $10, $0C, $EB, $02, $FB, $0F, $F0, $10, $92, $0C, $FB, $0F, $F0, $10
        .byte $8B, $0C, $EC, $EC, $EB, $03, $FB, $0F, $F0, $10, $9A, $0C, $EC, $FF
sound_27:
        .byte $04, $BE, $9A, $05, $AE, $9B, $02, $3D, $9D, $07, $96, $9D, $06, $BF, $9D, $FF
        .byte $E2, $C0, $E3, $09, $EB, $04, $E9, $D5, $9A, $EC, $E0, $05, $E3, $0A, $ED, $A6
        .byte $2B, $31, $33, $E0, $04, $33, $FF, $E0, $02, $95, $28, $ED, $E0, $05, $28, $E0
        .byte $04, $28, $EF, $E0, $02, $83, $28, $E0, $04, $8D, $28, $E0, $02, $83, $2A, $E0
        .byte $04, $8D, $2A, $E0, $02, $83, $2B, $E0, $04, $8D, $2B, $E0, $02, $89, $31, $ED
        .byte $E0, $05, $31, $E0, $04, $31, $EF, $E0, $02, $83, $2A, $E0, $04, $86, $2A, $E0
        .byte $02, $8F, $2A, $ED, $E0, $05, $2A, $E0, $04, $2A, $EF, $E0, $02, $83, $26, $E0
        .byte $04, $86, $26, $E0, $02, $83, $26, $E0, $04, $86, $26, $E0, $02, $83, $28, $E0
        .byte $04, $86, $28, $E0, $02, $83, $26, $E0, $04, $86, $26, $E0, $02, $83, $28, $E0
        .byte $04, $86, $28, $E0, $02, $83, $2A, $E0, $04, $86, $2A, $E0, $02, $95, $28, $ED
        .byte $E0, $05, $28, $E0, $04, $28, $EF, $E0, $02, $83, $28, $E0, $04, $8D, $28, $E0
        .byte $02, $83, $2A, $E0, $04, $8D, $2A, $E0, $02, $83, $28, $E0, $04, $8D, $28, $E0
        .byte $02, $8F, $27, $ED, $E0, $05, $27, $E0, $04, $27, $EF, $E0, $02, $83, $27, $E0
        .byte $04, $86, $27, $E0, $02, $83, $28, $E0, $04, $86, $28, $E0, $02, $8B, $2A, $ED
        .byte $E0, $05, $2A, $E0, $04, $2A, $EF, $E0, $02, $83, $2B, $E0, $04, $89, $2B, $E0
        .byte $02, $83, $2A, $E0, $04, $89, $2A, $E0, $02, $83, $26, $E0, $04, $89, $26, $EA
        .byte $E0, $05, $E2, $00, $E3, $0B, $E9, $FF, $9C, $E9, $FF, $9C, $E2, $80, $EB, $1B
        .byte $81, $23, $E5, $01, $23, $E5, $02, $23, $E5, $01, $23, $E5, $00, $EC, $EB, $09
        .byte $26, $E5, $01, $26, $E5, $02, $26, $E5, $01, $26, $E5, $00, $EC, $EB, $1B, $21
        .byte $E5, $01, $21, $E5, $02, $21, $E5, $01, $21, $E5, $00, $EC, $EB, $09, $23, $E5
        .byte $01, $23, $E5, $02, $23, $E5, $01, $23, $E5, $00, $EC, $EB, $1B, $24, $E5, $01
        .byte $24, $E5, $02, $24, $E5, $01, $24, $E5, $00, $EC, $EB, $09, $26, $E5, $01, $26
        .byte $E5, $02, $26, $E5, $01, $26, $E5, $00, $EC, $EB, $12, $23, $E5, $01, $23, $E5
        .byte $02, $23, $E5, $01, $23, $E5, $00, $EC, $EB, $09, $28, $E5, $01, $28, $E5, $02
        .byte $28, $E5, $01, $28, $E5, $00, $EC, $EB, $09, $2A, $E5, $01, $2A, $E5, $02, $2A
        .byte $E5, $01, $2A, $E5, $00, $EC, $EB, $1B, $23, $E5, $01, $23, $E5, $02, $23, $E5
        .byte $01, $23, $E5, $00, $EC, $EB, $09, $26, $E5, $01, $26, $E5, $02, $26, $E5, $01
        .byte $26, $E5, $00, $EC, $EB, $1B, $21, $E5, $01, $21, $E5, $02, $21, $E5, $01, $21
        .byte $E5, $00, $EC, $EB, $09, $23, $E5, $01, $23, $E5, $02, $23, $E5, $01, $23, $E5
        .byte $00, $EC, $EB, $1B, $24, $E5, $01, $24, $E5, $02, $24, $E5, $01, $24, $E5, $00
        .byte $EC, $EB, $09, $26, $E5, $01, $26, $E5, $02, $26, $E5, $01, $26, $E5, $00, $EC
        .byte $EB, $12, $23, $E5, $01, $23, $E5, $02, $23, $E5, $01, $23, $E5, $00, $EC, $EB
        .byte $09, $28, $E5, $01, $28, $E5, $02, $28, $E5, $01, $28, $E5, $00, $EC, $EB, $09
        .byte $2A, $E5, $01, $2A, $E5, $02, $2A, $E5, $01, $2A, $E5, $00, $EC, $E3, $0B, $EB
        .byte $24, $28, $E5, $01, $28, $E5, $02, $28, $E5, $01, $28, $E5, $00, $EC, $EB, $24
        .byte $2A, $E5, $01, $2A, $E5, $02, $2A, $E5, $01, $2A, $E5, $00, $EC, $EB, $24, $2B
        .byte $E5, $01, $2B, $E5, $02, $2B, $E5, $01, $2B, $E5, $00, $EC, $E0, $04, $A6, $2B
        .byte $FF, $EB, $24, $81, $18, $E5, $02, $18, $E5, $04, $18, $E5, $02, $18, $E5, $00
        .byte $EC, $EB, $24, $16, $E5, $02, $16, $E5, $04, $16, $E5, $02, $16, $E5, $00, $EC
        .byte $EB, $24, $14, $E5, $02, $14, $E5, $04, $14, $E5, $02, $14, $E5, $00, $EC, $EB
        .byte $24, $13, $E5, $02, $13, $E5, $04, $13, $E5, $02, $13, $E5, $00, $EC, $EA, $E0
        .byte $0C, $EB, $08, $A6, $0C, $EC, $EB, $02, $EB, $03, $E0, $0B, $8F, $28, $E0, $14
        .byte $86, $28, $28, $28, $EC, $E0, $0B, $8F, $2B, $2A, $EB, $03, $E0, $0B, $8F, $26
        .byte $E0, $14, $86, $26, $26, $26, $EC, $E0, $0B, $8F, $2A, $28, $EB, $03, $E0, $0B
        .byte $8F, $24, $E0, $14, $86, $24, $24, $24, $EC, $E0, $0B, $8F, $28, $26, $EB, $03
        .byte $E0, $0B, $8F, $23, $E0, $14, $86, $23, $23, $23, $EC, $E0, $0B, $8F, $23, $26
        .byte $EC, $E0, $0C, $A6, $24, $26, $28, $FF, $E0, $11, $E3, $05, $EB, $08, $A6, $10
        .byte $EC, $EB, $08, $EB, $03, $8F, $01, $86, $01, $01, $01, $EC, $8F, $01, $01, $EC
        .byte $EB, $03, $8F, $01, $10, $10, $01, $10, $01, $89, $01, $01, $01, $01, $EC, $01
        .byte $FF, $EB, $08, $A6, $0C, $EC, $EB, $08, $FB, $0F, $F0, $10, $97, $0C, $FB, $0F
        .byte $F4, $20, $0C, $EB, $02, $FB, $0F, $F0, $10, $8F, $0C, $EC, $FB, $0F, $F4, $20
        .byte $0C, $0C, $EC, $EB, $03, $EB, $04, $FB, $0F, $F4, $20, $89, $0C, $FB, $0F, $F4
        .byte $20, $0C, $0C, $EC, $EB, $02, $FB, $0F, $F4, $20, $0C, $0C, $EC, $EC, $FB, $0F
        .byte $F4, $20, $0C, $FF
sound_28:
        .byte $04, $12, $9E, $05, $58, $9E, $02, $6D, $9E, $07, $8A, $9E, $06, $43, $88, $FF
        .byte $E0, $04, $84, $0C, $E2, $40, $83, $0C, $E3, $0B, $0C, $ED, $EB, $0C, $8A, $28
        .byte $89, $28, $2A, $2A, $25, $8A, $25, $EC, $EB, $04, $8A, $28, $89, $28, $2A, $2A
        .byte $24, $8A, $24, $EC, $EB, $04, $8A, $28, $89, $28, $2A, $2A, $25, $8A, $25, $EC
        .byte $EB, $04, $8A, $27, $89, $27, $28, $28, $24, $8A, $24, $EC, $E0, $05, $E3, $0A
        .byte $96, $27, $E0, $04, $27, $FF, $81, $0C, $E0, $04, $84, $0C, $E2, $40, $83, $0C
        .byte $E3, $0C, $82, $0C, $89, $0C, $81, $0C, $E8, $1E, $9E, $82, $0C, $E0, $0C, $88
        .byte $0C, $A4, $0C, $0C, $0C, $0C, $25, $25, $20, $9C, $20, $8C, $20, $21, $22, $23
        .byte $A4, $25, $25, $20, $20, $96, $1B, $FF, $83, $10, $E0, $11, $83, $10, $E3, $05
        .byte $84, $10, $A4, $10, $10, $9C, $01, $01, $01, $8F, $10, $81, $10, $8F, $10, $01
        .byte $81, $10, $EB, $10, $8F, $01, $81, $10, $8F, $10, $01, $81, $10, $EC, $FF
sound_2C:
        .byte $06, $43, $88, $04, $C1, $9E, $05, $E6, $9E, $02, $08, $9F, $07, $20, $9F, $FF
        .byte $E0, $04, $E2, $40, $E3, $09, $ED, $87, $16, $20, $23, $18, $22, $28, $20, $2B
        .byte $0C, $28, $33, $2B, $35, $37, $0C, $0C, $E0, $05, $E3, $0A, $87, $38, $E0, $06
        .byte $E3, $06, $9C, $38, $FF, $E0, $00, $E2, $40, $E3, $08, $87, $26, $30, $33, $28
        .byte $32, $38, $30, $3B, $0C, $38, $43, $3B, $45, $47, $0C, $0C, $E0, $05, $E3, $0B
        .byte $E0, $06, $E3, $06, $9C, $48, $FF, $E0, $0B, $87, $16, $20, $23, $18, $22, $28
        .byte $20, $2B, $0C, $28, $33, $2B, $35, $37, $0C, $0C, $E0, $0C, $90, $38, $FF, $E0
        .byte $11, $E3, $0F, $EB, $03, $FB, $0F, $F4, $20, $87, $10, $01, $EC, $FB, $0F, $F0
        .byte $10, $10, $EB, $02, $FB, $0F, $F4, $20, $10, $01, $EC, $EB, $04, $FB, $0F, $F4
        .byte $20, $10, $EC, $FB, $0F, $F0, $10, $10, $FB, $0F, $F4, $20, $10, $FF
sound_2A:
        .byte $04, $5F, $9F, $05, $74, $9F, $02, $88, $9F, $07, $97, $9F, $06, $43, $88, $FF
        .byte $E0, $06, $E2, $00, $E3, $06, $86, $32, $30, $25, $8F, $22, $32, $30, $28, $8B
        .byte $29, $30, $8F, $32, $FF, $E0, $04, $E2, $C0, $E3, $09, $ED, $8F, $0C, $19, $20
        .byte $22, $24, $8B, $25, $27, $EF, $8F, $29, $FF, $E0, $0D, $8F, $0C, $22, $20, $19
        .byte $20, $8B, $19, $24, $E0, $0C, $22, $FF, $E0, $11, $E3, $05, $86, $00, $01, $02
        .byte $EB, $02, $FB, $0F, $F0, $10, $8B, $01, $EC, $02, $FB, $0F, $F4, $20, $01, $FB
        .byte $0F, $F0, $10, $01, $EB, $04, $FB, $0F, $F4, $20, $02, $EC, $FF
; Act VI, stage 4.
sound_2B:
        .byte $04, $CC, $9F, $05, $30, $A0, $02, $3C, $A0, $07, $61, $A0, $06, $76, $A0, $FF
        .byte $E0, $00, $E2, $40, $E3, $09, $E5, $01, $87, $33, $0C, $33, $0C, $30, $30, $8C
        .byte $32, $32, $87, $27, $27, $2A, $2A, $27, $27, $33, $17, $33, $1A, $30, $20, $8C
        .byte $32, $87, $0C, $20, $27, $17, $2A, $1A, $27, $20, $EB, $04, $87, $33, $17, $33
        .byte $1A, $30, $20, $8C, $32, $87, $0C, $20, $27, $17, $2A, $1A, $27, $20, $EC, $35
        .byte $15, $35, $17, $33, $1A, $8C, $32, $87, $0C, $1A, $2A, $15, $30, $17, $2A, $1A
        .byte $35, $12, $35, $15, $33, $17, $8C, $32, $87, $0C, $17, $27, $12, $37, $15, $32
        .byte $17, $E8, $F6, $9F, $E0, $04, $E2, $C0, $E3, $0B, $ED, $91, $0C, $E8, $D4, $9F
        .byte $A4, $0C, $0C, $E0, $0C, $20, $20, $18, $18, $1A, $17, $E0, $0D, $EB, $0F, $8C
        .byte $20, $EC, $1B, $EB, $0F, $18, $EC, $19, $EB, $07, $1A, $EC, $18, $EB, $07, $17
        .byte $EC, $18, $E8, $49, $A0, $E3, $04, $A4, $10, $10, $E0, $11, $8C, $01, $01, $01
        .byte $01, $01, $01, $01, $E0, $09, $01, $E8, $66, $A0, $A4, $0C, $0C, $EB, $17, $FB
        .byte $0F, $F0, $10, $94, $0C, $EC, $FB, $0F, $F4, $20, $8C, $0C, $EB, $02, $FB, $0F
        .byte $F4, $20, $87, $0C, $EC, $EB, $02, $EB, $03, $FB, $0F, $F0, $10, $94, $0C, $FB
        .byte $0F, $F4, $20, $0C, $EC, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $8C, $0C
        .byte $EB, $02, $FB, $0F, $F4, $20, $87, $0C, $EC, $EC, $EB, $03, $FB, $0F, $F0, $10
        .byte $94, $0C, $FB, $0F, $F4, $20, $0C, $EC, $FB, $0F, $F4, $20, $87, $0C, $FB, $0F
        .byte $F4, $20, $8C, $0C, $FB, $0F, $F4, $20, $87, $0C, $EB, $04, $FB, $0F, $F4, $20
        .byte $0C, $EC, $E8, $91, $A0
sound_29:
        .byte $04, $F1, $A0, $05, $12, $A1, $02, $30, $A1, $07, $48, $A1, $06, $49, $A1, $FF
        .byte $E0, $06, $E2, $80, $E3, $08, $ED, $87, $24, $21, $24, $27, $24, $27, $2A, $27
        .byte $2A, $31, $2A, $31, $34, $31, $34, $37, $34, $37, $E0, $04, $E3, $09, $9C, $3A
        .byte $FF, $E0, $06, $E2, $C0, $E3, $09, $87, $14, $17, $1A, $17, $1A, $21, $1A, $21
        .byte $24, $21, $24, $27, $24, $27, $2A, $27, $2A, $31, $E0, $04, $9C, $34, $FF, $E0
        .byte $0B, $87, $21, $24, $27, $2A, $27, $24, $21, $24, $27, $2A, $27, $24, $21, $24
        .byte $27, $2A, $27, $24, $E0, $0C, $21, $FF, $EB, $12, $FA, $0F, $F0, $10, $87, $0C
        .byte $EC, $FF
sound_26:
        .byte $04, $63, $A1, $05, $BA, $A1, $02, $0C, $A2, $07, $67, $A2, $06, $93, $A2, $FF
        .byte $E0, $04, $E2, $40, $E3, $0A, $ED, $A0, $0C, $EB, $02, $8A, $23, $1B, $25, $0C
        .byte $0C, $0C, $0C, $90, $26, $8A, $23, $25, $0C, $0C, $0C, $0C, $0C, $EC, $E3, $0A
        .byte $EB, $02, $EB, $02, $85, $26, $25, $8A, $23, $0C, $90, $28, $8A, $26, $25, $26
        .byte $EC, $EB, $02, $85, $28, $26, $8A, $25, $0C, $90, $2A, $8A, $28, $26, $28, $EC
        .byte $EC, $E3, $0A, $85, $26, $25, $26, $25, $28, $26, $28, $26, $2A, $28, $2A, $28
        .byte $2B, $2A, $2B, $31, $98, $33, $FF, $E0, $00, $E2, $80, $E3, $0A, $EB, $26, $8A
        .byte $18, $EC, $E0, $05, $E2, $C0, $E3, $0C, $82, $18, $1A, $1B, $21, $23, $24, $26
        .byte $83, $28, $2A, $EB, $02, $EB, $23, $81, $2B, $E5, $01, $2B, $E5, $02, $2B, $E5
        .byte $01, $2B, $E5, $00, $EC, $90, $2A, $EB, $23, $81, $28, $E5, $01, $28, $E5, $02
        .byte $28, $E5, $01, $28, $E5, $00, $EC, $90, $2A, $EC, $E0, $09, $E3, $09, $85, $EB
        .byte $08, $23, $EC, $EB, $08, $26, $EC, $23, $FF, $E0, $0B, $8A, $EB, $28, $18, $EC
        .byte $EB, $02, $E0, $10, $90, $1B, $8A, $0C, $90, $1B, $E0, $0B, $8A, $1B, $1B, $1B
        .byte $EC, $EB, $02, $E0, $10, $90, $21, $8A, $0C, $90, $21, $E0, $0B, $8A, $21, $21
        .byte $21, $EC, $EB, $02, $E0, $14, $85, $1B, $1B, $E0, $0B, $8A, $1B, $1B, $1B, $1B
        .byte $1B, $1B, $1B, $EC, $EB, $02, $E0, $14, $85, $21, $21, $E0, $0B, $8A, $21, $21
        .byte $21, $21, $21, $21, $21, $EC, $85, $23, $23, $8A, $23, $23, $23, $23, $23, $E0
        .byte $0C, $90, $23, $FF, $E3, $05, $EB, $05, $E0, $11, $EB, $07, $8A, $01, $EC, $E0
        .byte $09, $01, $EC, $E0, $11, $EB, $08, $85, $01, $01, $8A, $01, $01, $85, $01, $01
        .byte $8A, $01, $85, $01, $01, $01, $01, $01, $01, $EC, $EB, $10, $85, $01, $EC, $FF
        .byte $FB, $0F, $F0, $10, $8A, $0C, $0C, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F
        .byte $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $EB, $03, $FB, $0F, $F0, $10, $0C
        .byte $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10
        .byte $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F0, $10, $0C
        .byte $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $EB, $03, $FB, $0F
        .byte $F4, $20, $0C, $EC, $EC, $EB, $02, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F4
        .byte $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4
        .byte $20, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F4
        .byte $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4
        .byte $20, $0C, $EB, $02, $FB, $0F, $F4, $20, $85, $0C, $EC, $8A, $EC, $EB, $03, $FB
        .byte $0F, $F0, $10, $90, $0C, $FB, $0F, $F4, $20, $0C, $EC, $FB, $0F, $F4, $20, $85
        .byte $0C, $FB, $0F, $F4, $20, $8A, $0C, $EB, $05, $FB, $0F, $F4, $20, $85, $0C, $EC
        .byte $8A, $EB, $03, $FB, $0F, $F4, $20, $0C, $EC, $FB, $0F, $F0, $10, $0C, $EB, $02
        .byte $FB, $0F, $F4, $20, $85, $0C, $FB, $0F, $F4, $20, $8A, $0C, $EC, $EB, $02, $FB
        .byte $0F, $F4, $20, $0C, $EC, $FF
sound_2E:
        .byte $04, $89, $A3, $05, $B7, $A4, $02, $C3, $A4, $07, $11, $A5, $06, $29, $A5, $FF
        .byte $E0, $06, $E2, $80, $E3, $09, $EB, $08, $8B, $0C, $86, $10, $10, $EC, $EB, $02
        .byte $86, $20, $18, $17, $10, $8B, $30, $E2, $40, $86, $10, $10, $E2, $80, $8B, $2A
        .byte $E2, $40, $86, $10, $10, $E2, $80, $8B, $27, $E2, $40, $86, $10, $10, $E2, $80
        .byte $20, $18, $17, $10, $8B, $30, $E2, $40, $86, $10, $10, $E2, $80, $8B, $2A, $33
        .byte $86, $10, $13, $27, $28, $20, $18, $17, $10, $8B, $30, $E2, $40, $86, $10, $10
        .byte $E2, $80, $8B, $2A, $E2, $40, $86, $10, $10, $E2, $80, $8B, $27, $86, $10, $17
        .byte $20, $18, $17, $10, $8B, $30, $E2, $40, $86, $10, $10, $E2, $80, $8B, $2A, $33
        .byte $86, $10, $13, $8B, $27, $86, $1A, $18, $13, $0A, $8B, $2A, $E2, $40, $86, $0A
        .byte $0A, $E2, $80, $8B, $28, $E2, $40, $86, $0A, $0A, $E2, $80, $8B, $27, $E2, $40
        .byte $86, $0A, $0A, $E2, $80, $86, $1A, $18, $13, $0A, $8B, $2A, $E2, $40, $86, $0A
        .byte $0A, $E2, $80, $8B, $28, $33, $86, $0A, $11, $13, $14, $86, $1A, $18, $13, $0A
        .byte $8B, $2A, $E2, $40, $86, $0A, $0A, $E2, $80, $8B, $28, $E2, $40, $86, $0A, $0A
        .byte $E2, $80, $8B, $27, $E2, $40, $86, $0A, $0A, $E2, $80, $86, $1A, $18, $13, $0A
        .byte $8B, $2A, $E2, $40, $86, $0A, $0A, $E2, $80, $8B, $28, $33, $E2, $40, $86, $0A
        .byte $0A, $E2, $80, $8B, $27, $EC, $E2, $C0, $8B, $0C, $25, $23, $21, $23, $28, $0C
        .byte $2A, $0C, $27, $23, $21, $23, $28, $26, $28, $0C, $26, $27, $28, $2A, $31, $0C
        .byte $2B, $97, $26, $8B, $27, $28, $2A, $86, $19, $1A, $21, $23, $97, $24, $23, $92
        .byte $21, $97, $2A, $31, $92, $2A, $97, $29, $2A, $86, $29, $2A, $8B, $31, $97, $33
        .byte $EB, $05, $84, $33, $85, $34, $83, $0C, $EC, $E2, $80, $E8, $97, $A3, $E0, $04
        .byte $E2, $80, $E3, $0B, $ED, $86, $0C, $E8, $8F, $A3, $E0, $16, $A2, $0C, $0C, $EB
        .byte $02, $EB, $02, $97, $20, $23, $92, $25, $8B, $0C, $97, $26, $92, $25, $23, $EC
        .byte $EB, $02, $97, $1A, $21, $92, $23, $8B, $0C, $97, $24, $92, $23, $21, $EC, $EC
        .byte $92, $24, $28, $29, $2A, $27, $28, $2A, $31, $2B, $2A, $28, $26, $29, $28, $30
        .byte $19, $1A, $20, $23, $25, $21, $23, $25, $26, $29, $28, $26, $24, $23, $8B, $0C
        .byte $22, $0C, $22, $0C, $22, $E8, $C8, $A4, $E0, $11, $E3, $07, $86, $01, $01, $01
        .byte $01, $10, $10, $02, $01, $10, $01, $01, $10, $02, $10, $01, $01, $E8, $15, $A5
        .byte $FB, $0F, $F0, $10, $8B, $0C, $0C, $EB, $03, $0C, $FB, $0F, $F0, $10, $0C, $EC
        .byte $FB, $0F, $F4, $20, $8B, $0C, $EB, $03, $FB, $0F, $F4, $20, $86, $0C, $EC, $0C
        .byte $0C, $EB, $09, $FB, $0F, $F4, $20, $0C, $EC, $EB, $0F, $FB, $0F, $F0, $10, $92
        .byte $0C, $FB, $0F, $F4, $20, $8B, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0
        .byte $10, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $EC, $FB, $0F, $F0
        .byte $10, $0C, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $86, $0C, $EB
        .byte $02, $FB, $0F, $F4, $20, $0C, $EC, $0C, $0C, $EB, $03, $FB, $0F, $F4, $20, $0C
        .byte $EC, $EB, $03, $8B, $0C, $EB, $02, $FB, $0F, $F0, $10, $0C, $EC, $0C, $0C, $FB
        .byte $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $0C, $0C, $FB, $0F, $F4, $20, $0C
        .byte $FB, $0F, $F0, $10, $0C, $0C, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F4
        .byte $20, $0C, $EC, $0C, $EB, $02, $FB, $0F, $F0, $10, $0C, $EC, $0C, $0C, $FB, $0F
        .byte $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $0C, $0C, $FB, $0F, $F4, $20, $0C, $FB
        .byte $0F, $F0, $10, $0C, $EB, $05, $FB, $0F, $F4, $20, $0C, $EC, $E8, $52, $A5
sound_2F:
        .byte $04, $08, $A6, $05, $42, $A6, $02, $82, $A6, $07, $8E, $A6, $06, $B5, $A6, $FF
        .byte $E0, $06, $E2, $C0, $E3, $08, $E5, $01, $8F, $EB, $08, $18, $EC, $EB, $08, $1B
        .byte $EC, $EB, $08, $22, $EC, $E3, $0A, $E0, $00, $E2, $C0, $EB, $02, $89, $38, $37
        .byte $36, $33, $EC, $E3, $0A, $E0, $04, $E2, $80, $97, $23, $23, $E0, $05, $E3, $0C
        .byte $A6, $25, $27, $28, $2A, $E0, $04, $97, $2A, $FF, $E0, $04, $E2, $80, $E3, $0B
        .byte $ED, $84, $0C, $8F, $EB, $08, $28, $EC, $EB, $08, $2B, $EC, $32, $32, $32, $32
        .byte $32, $32, $32, $8C, $32, $E3, $0B, $E2, $80, $85, $0C, $89, $38, $37, $36, $33
        .byte $38, $37, $36, $84, $33, $E0, $04, $E3, $0A, $97, $26, $27, $E0, $05, $E3, $0A
        .byte $A6, $28, $2B, $30, $31, $E0, $04, $97, $31, $FF, $E0, $0C, $A6, $18, $1B, $22
        .byte $23, $1B, $23, $25, $24, $FF, $E0, $11, $E3, $05, $EB, $0C, $8F, $10, $01, $EC
        .byte $89, $01, $01, $01, $01, $02, $02, $02, $03, $03, $10, $9B, $10, $EB, $04, $97
        .byte $01, $89, $10, $10, $01, $01, $8F, $01, $01, $01, $01, $EC, $FF, $EB, $0E, $FB
        .byte $0F, $F0, $10, $97, $0C, $EC, $EB, $08, $FB, $0F, $F4, $20, $89, $0C, $EC, $EB
        .byte $04, $FB, $0F, $F4, $20, $97, $0C, $FB, $0F, $F0, $10, $8F, $0C, $EB, $02, $FB
        .byte $0F, $F4, $20, $89, $0C, $EC, $EB, $04, $FB, $0F, $F4, $20, $8F, $0C, $EC, $EC
        .byte $FF
; Act IV, stage 3.
sound_30:
        .byte $04, $F9, $A6, $05, $13, $A7, $02, $1F, $A7, $07, $63, $A7, $06, $89, $A7, $FF
        .byte $E0, $06, $E2, $C0, $E3, $09, $8E, $24, $25, $24, $1B, $24, $25, $24, $1B, $23
        .byte $24, $23, $1B, $23, $24, $23, $1B, $E8, $FF, $A6, $E0, $04, $E2, $80, $E3, $0D
        .byte $ED, $92, $0C, $E8, $FF, $A6, $EB, $02, $E0, $16, $9E, $24, $24, $20, $96, $20
        .byte $E0, $0E, $88, $0C, $0C, $22, $23, $EC, $EB, $02, $E0, $16, $9E, $24, $8E, $0C
        .byte $96, $24, $E0, $0E, $8E, $24, $E0, $16, $9E, $20, $8E, $0C, $96, $20, $E0, $0E
        .byte $88, $22, $23, $EC, $8E, $24, $24, $24, $24, $24, $24, $24, $24, $20, $20, $20
        .byte $20, $20, $20, $20, $88, $24, $25, $E8, $4D, $A7, $E0, $11, $E3, $05, $EB, $07
        .byte $8E, $10, $10, $10, $01, $EC, $10, $10, $10, $88, $01, $02, $EB, $02, $EB, $07
        .byte $8E, $10, $01, $EC, $88, $01, $02, $EC, $8E, $02, $88, $01, $01, $E8, $81, $A7
        .byte $EB, $07, $FB, $0F, $F0, $10, $9E, $0C, $EC, $FB, $0F, $F0, $10, $96, $0C, $8E
        .byte $0C, $EB, $02, $FB, $0F, $F0, $10, $88, $0C, $EC, $EB, $02, $FB, $0F, $F0, $10
        .byte $9E, $0C, $8E, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB
        .byte $0F, $F0, $10, $9E, $0C, $8E, $0C, $FB, $0F, $F0, $10, $0C, $0C, $EB, $02, $FB
        .byte $0F, $F0, $10, $88, $0C, $EC, $EC, $EB, $1E, $FB, $0F, $F0, $10, $8E, $0C, $EC
        .byte $EB, $04, $FB, $0F, $F4, $20, $88, $0C, $EC, $EB, $03, $EB, $02, $FB, $0F, $F0
        .byte $10, $8E, $0C, $EC, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $EC, $EB
        .byte $02, $FB, $0F, $F0, $10, $0C, $EC, $FB, $0F, $F4, $20, $0C, $EB, $02, $FB, $0F
        .byte $F4, $20, $88, $0C, $EC, $E8, $E2, $A7
; Act V, stage 3.
sound_31:
        .byte $04, $21, $A8, $05, $9F, $A8, $02, $AA, $A8, $07, $0E, $A9, $06, $21, $A9, $FF
        .byte $E0, $04, $E2, $C0, $E3, $0B, $ED, $87, $28, $27, $E9, $62, $A8, $E9, $72, $A8
        .byte $94, $20, $E9, $62, $A8, $E9, $72, $A8, $E9, $7E, $A8, $8C, $20, $87, $25, $27
        .byte $E9, $62, $A8, $E9, $72, $A8, $8C, $20, $87, $25, $27, $E9, $62, $A8, $E9, $72
        .byte $A8, $94, $20, $E9, $62, $A8, $E9, $72, $A8, $E9, $7E, $A8, $94, $20, $E8, $33
        .byte $A8, $EB, $03, $8C, $28, $25, $2A, $25, $30, $25, $87, $31, $30, $2A, $28, $EC
        .byte $EA, $8C, $28, $25, $87, $27, $2A, $28, $27, $8C, $25, $28, $EA, $8C, $20, $87
        .byte $1A, $20, $8C, $21, $23, $87, $1A, $20, $21, $23, $8C, $25, $21, $87, $23, $25
        .byte $27, $28, $8C, $2A, $25, $87, $27, $2A, $28, $25, $8C, $23, $27, $EA, $E0, $04
        .byte $E2, $80, $E3, $0C, $87, $0C, $E8, $28, $A8, $8C, $0C, $E9, $C4, $A8, $E9, $E8
        .byte $A8, $E9, $FC, $A8, $E9, $E8, $A8, $E9, $C4, $A8, $E9, $E8, $A8, $E9, $FC, $A8
        .byte $E8, $AF, $A8, $E0, $0E, $94, $25, $8C, $0C, $25, $0C, $25, $94, $25, $23, $8C
        .byte $0C, $23, $0C, $23, $94, $23, $21, $8C, $0C, $21, $0C, $21, $94, $21, $20, $8C
        .byte $0C, $20, $0C, $20, $94, $20, $EA, $E0, $0B, $EB, $08, $8C, $25, $EC, $EB, $08
        .byte $23, $EC, $EB, $08, $21, $EC, $EB, $08, $20, $EC, $EA, $8C, $23, $23, $23, $23
        .byte $21, $21, $21, $21, $1A, $1A, $1A, $1A, $23, $23, $94, $25, $EA, $E0, $11, $E3
        .byte $05, $A4, $10, $10, $10, $10, $8C, $01, $01, $01, $87, $02, $01, $E8, $17, $A9
        .byte $8C, $0C, $EB, $03, $FB, $0F, $F0, $10, $8C, $0C, $0C, $0C, $FB, $0F, $F0, $10
        .byte $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F0, $10, $0C, $0C, $EC, $FB, $0F
        .byte $F0, $10, $0C, $0C, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C
        .byte $FB, $0F, $F4, $20, $8C, $0C, $EB, $02, $FB, $0F, $F4, $20, $87, $0C, $EC, $EB
        .byte $03, $FB, $0F, $F0, $10, $8C, $0C, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0
        .byte $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $0C, $EC, $FB
        .byte $0F, $F0, $10, $0C, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $0C
        .byte $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $EB, $02, $FB, $0F, $F4, $20
        .byte $87, $0C, $EC, $E8, $60, $A9
sound_33:
        .byte $04, $B7, $A9, $05, $05, $AA, $02, $43, $88, $07, $43, $88, $06, $43, $88, $FF
        .byte $E0, $04, $E2, $40, $E3, $09, $94, $E9, $D3, $A9, $E9, $D3, $A9, $E9, $EC, $A9
        .byte $E9, $D3, $A9, $E9, $D3, $A9, $FE, $88, $E9, $EC, $A9, $FF, $EB, $02, $19, $20
        .byte $22, $EC, $EB, $02, $18, $20, $22, $EC, $EB, $02, $17, $1B, $20, $EC, $EB, $02
        .byte $16, $1B, $20, $EC, $EA, $EB, $02, $15, $1B, $20, $EC, $EB, $02, $14, $1B, $20
        .byte $EC, $EB, $02, $13, $1B, $20, $EC, $12, $15, $18, $1B, $20, $22, $EA, $E2, $80
        .byte $E3, $0A, $E5, $01, $E9, $20, $AA, $E9, $20, $AA, $E9, $52, $AA, $E9, $20, $AA
        .byte $E9, $20, $AA, $FE, $88, $E9, $52, $AA, $FF, $E0, $05, $9C, $34, $ED, $A1, $34
        .byte $E0, $04, $94, $34, $EF, $E0, $05, $94, $35, $ED, $35, $E0, $04, $35, $EF, $37
        .byte $30, $32, $E0, $05, $9C, $34, $ED, $A1, $34, $E0, $04, $94, $34, $EF, $E0, $05
        .byte $9C, $32, $ED, $A1, $32, $E0, $04, $94, $32, $EF, $EA, $E9, $6D, $AA, $E0, $05
        .byte $9C, $30, $ED, $E0, $04, $94, $30, $EF, $E9, $6D, $AA, $E0, $05, $94, $37, $ED
        .byte $E0, $04, $37, $EF, $35, $EA, $E0, $05, $94, $32, $ED, $32, $E0, $04, $32, $EF
        .byte $E0, $05, $30, $ED, $30, $E0, $04, $30, $EF, $E0, $05, $2B, $ED, $2B, $E0, $04
        .byte $2B, $EF, $EA
sound_34:
        .byte $04, $9A, $AA, $05, $19, $AB, $02, $24, $AC, $07, $A8, $AC, $06, $C0, $AC, $FF
        .byte $E0, $04, $E2, $40, $E3, $09, $90, $EB, $04, $14, $1B, $24, $1B, $EC, $EB, $02
        .byte $09, $14, $19, $14, $EC, $12, $19, $22, $19, $10, $19, $22, $19, $0B, $16, $1B
        .byte $16, $1B, $19, $17, $16, $EB, $02, $EB, $02, $E0, $05, $E3, $0B, $A0, $27, $98
        .byte $27, $E0, $04, $27, $EC, $EB, $02, $E0, $05, $A0, $29, $98, $29, $E0, $04, $29
        .byte $EC, $EC, $E3, $09, $90, $10, $17, $20, $17, $24, $22, $20, $17, $12, $19, $22
        .byte $19, $26, $24, $22, $19, $14, $1B, $24, $1B, $27, $26, $24, $1B, $15, $20, $25
        .byte $20, $29, $27, $25, $29, $17, $22, $27, $29, $2B, $32, $37, $2B, $98, $ED, $30
        .byte $2B, $EF, $29, $ED, $27, $EF, $E0, $05, $98, $36, $36, $E0, $04, $36, $FF, $E0
        .byte $05, $E2, $C0, $E3, $0C, $ED, $A0, $17, $98, $16, $14, $EF, $E3, $0A, $90, $27
        .byte $ED, $27, $E0, $04, $27, $EF, $27, $29, $27, $8A, $26, $90, $27, $E0, $05, $8A
        .byte $30, $90, $30, $ED, $30, $E0, $04, $30, $EF, $30, $30, $2B, $8A, $29, $90, $27
        .byte $E0, $05, $8A, $26, $90, $26, $ED, $26, $E0, $04, $26, $EF, $26, $26, $24, $22
        .byte $8A, $26, $E0, $05, $1B, $95, $1B, $ED, $1B, $E0, $04, $90, $1B, $EF, $1B, $20
        .byte $22, $24, $EB, $02, $E0, $05, $90, $34, $ED, $34, $E0, $04, $34, $EF, $34, $34
        .byte $32, $8A, $2B, $90, $32, $E0, $05, $8A, $34, $90, $34, $ED, $34, $E0, $04, $34
        .byte $EF, $34, $34, $37, $36, $8A, $34, $E0, $05, $32, $90, $32, $ED, $32, $E0, $04
        .byte $32, $EF, $32, $32, $30, $2B, $8A, $30, $E0, $05, $32, $90, $32, $ED, $32, $E0
        .byte $04, $32, $EF, $30, $2B, $2B, $8A, $30, $E0, $05, $32, $ED, $32, $E0, $04, $32
        .byte $EF, $EC, $E0, $05, $95, $34, $ED, $34, $E0, $04, $34, $EF, $8A, $0C, $34, $34
        .byte $34, $34, $34, $37, $E0, $05, $95, $36, $ED, $36, $E0, $04, $36, $EF, $8A, $0C
        .byte $36, $36, $36, $36, $36, $39, $E0, $05, $95, $37, $ED, $37, $E0, $04, $37, $EF
        .byte $8A, $0C, $37, $37, $37, $37, $37, $3B, $E0, $05, $95, $39, $ED, $39, $E0, $04
        .byte $90, $39, $EF, $39, $3B, $40, $39, $E0, $05, $95, $3B, $ED, $3B, $E0, $04, $90
        .byte $3B, $EF, $40, $3B, $39, $40, $8A, $EB, $04, $40, $3B, $39, $37, $EC, $E0, $05
        .byte $98, $3B, $ED, $9D, $3B, $E0, $04, $98, $3B, $FF, $E0, $0D, $EB, $02, $9D, $24
        .byte $90, $24, $A0, $24, $EC, $9D, $19, $90, $19, $A0, $19, $9D, $22, $90, $22, $9D
        .byte $20, $90, $20, $9D, $1B, $90, $1B, $98, $1B, $1B, $EB, $02, $EB, $02, $90, $20
        .byte $17, $22, $E0, $0C, $98, $20, $E0, $0D, $20, $90, $20, $EC, $EB, $02, $1B, $17
        .byte $19, $E0, $0C, $98, $1B, $E0, $0D, $1B, $90, $1B, $EC, $EC, $E0, $16, $9D, $20
        .byte $98, $20, $E0, $0D, $8A, $17, $17, $E0, $16, $90, $17, $20, $9D, $22, $98, $22
        .byte $E0, $0D, $8A, $19, $19, $E0, $16, $90, $19, $22, $9D, $24, $98, $24, $E0, $0D
        .byte $8A, $1B, $1B, $E0, $16, $90, $1B, $24, $9D, $25, $98, $25, $90, $20, $20, $25
        .byte $98, $27, $25, $24, $22, $27, $22, $1B, $22, $E0, $0C, $A0, $27, $FF, $E3, $05
        .byte $EB, $0A, $A0, $10, $EC, $EB, $08, $E0, $12, $90, $01, $01, $02, $01, $01, $01
        .byte $02, $E0, $09, $01, $EC, $FF, $EB, $09, $A0, $0C, $EC, $FB, $0F, $F4, $20, $8A
        .byte $0C, $FB, $0F, $F4, $20, $0C, $0C, $FB, $0F, $F4, $20, $0C, $EB, $02, $FB, $0F
        .byte $F4, $20, $90, $0C, $EC, $EB, $03, $FB, $0F, $F0, $10, $90, $0C, $0C, $FB, $0F
        .byte $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F
        .byte $F4, $20, $0C, $0C, $EC, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F4, $20, $0C
        .byte $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C
        .byte $EB, $02, $FB, $0F, $F4, $20, $8A, $0C, $EC, $EB, $03, $FB, $0F, $F0, $10, $90
        .byte $0C, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0
        .byte $10, $0C, $FB, $0F, $F4, $20, $0C, $0C, $EC, $FB, $0F, $F0, $10, $0C, $0C, $FB
        .byte $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $8A, $0C, $FB
        .byte $0F, $F4, $20, $0C, $0C, $EB, $05, $FB, $0F, $F4, $20, $0C, $EC, $FF
; Act III, stage 1.
sound_2D:
        .byte $04, $78, $AD, $05, $AB, $AD, $02, $E1, $AD, $07, $FE, $AD, $06, $0A, $AE, $FF
        .byte $E0, $04, $E2, $40, $E3, $0A, $ED, $8A, $20, $25, $27, $90, $28, $8A, $27, $25
        .byte $27, $23, $25, $27, $90, $28, $8A, $27, $25, $27, $22, $25, $27, $90, $28, $8A
        .byte $27, $25, $27, $21, $25, $27, $25, $85, $25, $28, $25, $21, $28, $25, $27, $28
        .byte $E8, $7F, $AD, $E0, $09, $E2, $40, $E3, $0A, $85, $EB, $03, $15, $17, $15, $15
        .byte $EC, $15, $17, $15, $17, $EB, $03, $18, $1A, $18, $18, $EC, $18, $1A, $18, $15
        .byte $EB, $04, $17, $18, $17, $17, $EC, $EB, $02, $1A, $17, $1A, $1A, $EC, $1A, $1B
        .byte $1B, $17, $1A, $1A, $1A, $1A, $E8, $B1, $AD, $E0, $10, $EB, $04, $8A, $25, $25
        .byte $EC, $EB, $04, $18, $28, $EC, $EB, $04, $17, $27, $EC, $1A, $2A, $1A, $2A, $21
        .byte $31, $21, $31, $E8, $E3, $AD, $E0, $11, $E3, $06, $85, $02, $10, $01, $01, $E8
        .byte $02, $AE, $EB, $03, $FB, $0F, $F0, $10, $90, $0C, $FB, $0F, $F4, $20, $0C, $8A
        .byte $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C
        .byte $EC, $FB, $0F, $F0, $10, $90, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10
        .byte $85, $0C, $FB, $0F, $F4, $20, $0C, $0C, $EB, $05, $FB, $0F, $F4, $20, $0C, $EC
        .byte $E8, $0A, $AE
sound_48:
        .byte $04, $5B, $AE, $05, $7C, $AE, $02, $9D, $AE, $07, $43, $88, $06, $43, $88, $FF
        .byte $E0, $05, $E2, $40, $E3, $04, $87, $2A, $29, $28, $81, $FE, $08, $EB, $0A, $27
        .byte $E5, $01, $27, $E5, $02, $27, $E5, $03, $27, $E5, $02, $27, $E5, $01, $27, $EC
        .byte $FF, $E0, $05, $E2, $80, $E3, $07, $87, $24, $23, $22, $81, $FE, $08, $EB, $0A
        .byte $21, $E5, $02, $21, $E5, $04, $21, $E5, $06, $21, $E5, $04, $21, $E5, $02, $21
        .byte $EC, $FF, $E0, $0C, $9C, $27, $FF
sound_4A:
        .byte $04, $B2, $AE, $05, $32, $AF, $02, $85, $AF, $07, $9E, $AF, $06, $B8, $AF, $FF
        .byte $E0, $04, $E2, $C0, $E3, $08, $ED, $E9, $D0, $AE, $A0, $28, $90, $0C, $E9, $D0
        .byte $AE, $E0, $05, $E3, $09, $EF, $98, $28, $ED, $28, $E0, $04, $28, $FF, $90, $23
        .byte $95, $2B, $8A, $2A, $A0, $23, $90, $0C, $23, $95, $26, $85, $23, $26, $A0, $28
        .byte $90, $0C, $28, $95, $31, $8A, $2B, $95, $2B, $8A, $2A, $95, $2A, $8A, $28, $95
        .byte $28, $8A, $26, $AA, $2A, $8C, $28, $AA, $26, $A0, $23, $90, $0C, $23, $95, $26
        .byte $8A, $24, $95, $23, $8A, $21, $9D, $21, $90, $21, $95, $24, $8A, $23, $9D, $1B
        .byte $8A, $1B, $23, $98, $28, $AA, $28, $8C, $2A, $AA, $2B, $95, $2A, $8A, $26, $95
        .byte $26, $8A, $23, $26, $90, $23, $8A, $23, $AA, $26, $8C, $23, $AA, $8B, $2A, $EA
        .byte $E0, $04, $E2, $80, $E3, $09, $9D, $0C, $E9, $52, $AF, $EB, $02, $90, $18, $23
        .byte $28, $23, $EC, $E9, $52, $AF, $E0, $05, $E3, $0A, $A0, $18, $E0, $04, $18, $FF
        .byte $EB, $02, $90, $18, $23, $28, $23, $EC, $EB, $02, $14, $1B, $24, $1B, $EC, $EB
        .byte $02, $16, $21, $26, $21, $EC, $EB, $02, $0B, $16, $1B, $16, $EC, $EB, $02, $11
        .byte $18, $21, $18, $EC, $EB, $02, $18, $23, $28, $23, $EC, $EB, $02, $13, $1A, $23
        .byte $1A, $EC, $EA, $E0, $0C, $9D, $0C, $EB, $10, $A0, $0C, $EC, $18, $18, $24, $24
        .byte $26, $26, $1B, $1B, $21, $21, $18, $18, $23, $23, $18, $FF, $E3, $05, $81, $00
        .byte $83, $10, $9C, $10, $EB, $10, $A0, $10, $EC, $EB, $0E, $E0, $11, $90, $01, $01
        .byte $01, $E0, $09, $01, $EC, $FF, $9D, $0C, $EB, $0F, $A0, $0C, $EC, $FB, $0F, $F4
        .byte $20, $8A, $0C, $FB, $0F, $F4, $20, $90, $0C, $FB, $0F, $F4, $20, $8A, $0C, $EB
        .byte $02, $FB, $0F, $F4, $20, $90, $0C, $EC, $EB, $0E, $FB, $0F, $F0, $10, $98, $0C
        .byte $FB, $0F, $F4, $20, $0C, $EC, $FF
sound_4B:
        .byte $04, $F9, $AF, $05, $70, $B0, $02, $34, $B1, $07, $A1, $B1, $06, $EE, $B1, $FF
        .byte $E0, $04, $E2, $40, $E3, $0B, $ED, $EB, $02, $EB, $04, $8F, $26, $25, $EC, $EB
        .byte $04, $25, $24, $EC, $EC, $E9, $47, $B0, $ED, $E3, $0A, $EB, $02, $EB, $04, $8F
        .byte $33, $32, $EC, $EB, $04, $32, $31, $EC, $EC, $EB, $02, $EB, $04, $35, $34, $EC
        .byte $EB, $04, $34, $33, $EC, $EC, $EB, $04, $36, $35, $EC, $EB, $04, $37, $36, $EC
        .byte $EB, $04, $38, $37, $EC, $EB, $03, $39, $38, $EC, $39, $3B, $40, $FF, $89, $1A
        .byte $8F, $1B, $89, $0C, $1B, $20, $8F, $21, $89, $0C, $21, $8F, $22, $89, $0C, $22
        .byte $23, $8F, $24, $89, $0C, $24, $8F, $25, $89, $0C, $24, $25, $93, $27, $28, $EF
        .byte $29, $2A, $2B, $30, $31, $32, $EA, $E0, $04, $E2, $80, $E3, $0C, $89, $0C, $EB
        .byte $04, $8F, $26, $25, $EC, $EB, $04, $25, $24, $EC, $EB, $04, $26, $25, $EC, $EB
        .byte $03, $25, $24, $EC, $25, $89, $24, $E3, $0B, $89, $0A, $8F, $0B, $89, $0C, $0B
        .byte $10, $8F, $11, $89, $0C, $11, $8F, $12, $89, $0C, $12, $13, $8F, $14, $89, $0C
        .byte $14, $8F, $15, $89, $0C, $14, $15, $93, $17, $18, $19, $1A, $1B, $20, $21, $22
        .byte $E0, $05, $E2, $C0, $EB, $02, $EB, $12, $82, $23, $E5, $01, $23, $E5, $02, $23
        .byte $E5, $01, $23, $E5, $00, $EC, $EB, $12, $22, $E5, $01, $22, $E5, $02, $22, $E5
        .byte $01, $22, $E5, $00, $EC, $EC, $EB, $02, $EB, $12, $25, $E5, $01, $25, $E5, $02
        .byte $25, $E5, $01, $25, $E5, $00, $EC, $EB, $12, $24, $E5, $01, $24, $E5, $02, $24
        .byte $E5, $01, $24, $E5, $00, $EC, $EC, $EB, $12, $26, $E5, $01, $26, $E5, $02, $26
        .byte $E5, $01, $26, $E5, $00, $EC, $EB, $12, $27, $E5, $01, $27, $E5, $02, $27, $E5
        .byte $01, $27, $E5, $00, $EC, $EB, $12, $28, $E5, $01, $28, $E5, $02, $28, $E5, $01
        .byte $28, $E5, $00, $EC, $A3, $29, $8F, $29, $2B, $30, $FF, $EB, $02, $E0, $16, $A3
        .byte $20, $8F, $0C, $E0, $0B, $89, $21, $20, $E0, $16, $A3, $1B, $8F, $0C, $E0, $0B
        .byte $89, $1A, $1B, $EC, $E9, $47, $B0, $EB, $02, $E0, $16, $A3, $19, $8F, $0C, $E0
        .byte $0B, $89, $19, $1A, $E0, $16, $A3, $18, $8F, $0C, $E0, $0B, $89, $17, $18, $EC
        .byte $E0, $0D, $EB, $02, $97, $19, $19, $19, $8F, $19, $1A, $97, $18, $18, $18, $8F
        .byte $17, $18, $EC, $8F, $20, $20, $20, $20, $20, $20, $20, $21, $1B, $1B, $1B, $1B
        .byte $1B, $1B, $1B, $20, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1B, $19, $19, $19, $19
        .byte $19, $19, $18, $17, $E0, $0C, $16, $FF, $E0, $11, $E3, $05, $EB, $04, $97, $01
        .byte $8F, $10, $01, $10, $01, $10, $01, $EC, $EB, $02, $89, $01, $8F, $01, $89, $10
        .byte $01, $EC, $8F, $01, $89, $10, $01, $01, $8F, $01, $89, $10, $01, $8F, $01, $89
        .byte $10, $01, $01, $EB, $08, $93, $01, $EC, $EB, $04, $97, $01, $8F, $10, $01, $10
        .byte $01, $10, $01, $EC, $EB, $08, $E0, $11, $8F, $01, $01, $01, $01, $01, $01, $01
        .byte $E0, $09, $01, $EC, $FF, $EB, $10, $FB, $0F, $F0, $10, $97, $0C, $EC, $EB, $02
        .byte $FB, $0F, $F0, $10, $89, $0C, $FB, $0F, $F0, $10, $93, $0C, $FB, $0F, $F0, $10
        .byte $89, $0C, $EC, $FB, $0F, $F0, $10, $93, $0C, $EB, $02, $FB, $0F, $F0, $10, $89
        .byte $0C, $EC, $EB, $02, $FB, $0F, $F0, $10, $93, $0C, $FB, $0F, $F0, $10, $89, $0C
        .byte $EC, $FB, $0F, $F0, $10, $0C, $EB, $05, $FB, $0F, $F0, $10, $93, $0C, $EC, $FB
        .byte $0F, $F4, $20, $89, $0C, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F4, $20, $0C
        .byte $0C, $EB, $04, $FB, $0F, $F4, $20, $0C, $EC, $EB, $07, $FB, $0F, $F0, $10, $97
        .byte $0C, $FB, $0F, $F4, $20, $0C, $EC, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20
        .byte $8F, $0C, $EB, $02, $FB, $0F, $F4, $20, $89, $0C, $EC, $EB, $02, $FB, $0F, $F0
        .byte $10, $97, $0C, $FB, $0F, $F4, $20, $8F, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB
        .byte $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $0C, $0C, $FB, $0F, $F0, $10, $0C
        .byte $FB, $0F, $F4, $20, $0C, $0C, $FB, $0F, $F0, $10, $0C, $0C, $EB, $04, $FB, $0F
        .byte $F4, $20, $89, $0C, $EC, $EC, $EB, $07, $FB, $0F, $F0, $10, $97, $0C, $FB, $0F
        .byte $F4, $20, $0C, $EC, $EB, $09, $FB, $0F, $F4, $20, $89, $0C, $EC, $FF
sound_4C:
        .byte $04, $D7, $B2, $05, $1C, $B3, $02, $5E, $B3, $07, $A8, $B3, $06, $D9, $B3, $FF
        .byte $E2, $C0, $E3, $0C, $ED, $EB, $02, $E0, $05, $A1, $32, $E0, $04, $94, $32, $E0
        .byte $05, $A1, $30, $E0, $04, $94, $30, $E0, $05, $A1, $2B, $E0, $04, $94, $2B, $E0
        .byte $05, $A1, $2A, $E0, $04, $94, $2A, $EC, $EF, $E0, $05, $9C, $29, $94, $29, $ED
        .byte $2A, $9C, $2B, $94, $2B, $2A, $EF, $9C, $29, $94, $29, $ED, $2A, $9C, $2B, $94
        .byte $2B, $31, $E8, $DC, $B2, $E2, $40, $E3, $0B, $EB, $02, $E0, $05, $A1, $25, $E0
        .byte $04, $94, $25, $E0, $05, $A1, $24, $E0, $04, $94, $24, $E0, $05, $A1, $27, $E0
        .byte $04, $94, $27, $E0, $05, $A1, $27, $E0, $04, $94, $27, $EC, $E3, $0C, $E0, $05
        .byte $9C, $24, $94, $24, $24, $9C, $25, $94, $25, $25, $9C, $24, $94, $24, $24, $9C
        .byte $28, $94, $28, $28, $E8, $1E, $B3, $E0, $0E, $EB, $02, $EB, $03, $94, $22, $89
        .byte $22, $8A, $22, $89, $22, $94, $22, $22, $EC, $94, $22, $EB, $03, $89, $22, $8A
        .byte $22, $89, $22, $EC, $EC, $94, $29, $89, $29, $8A, $29, $89, $29, $94, $29, $29
        .byte $28, $89, $28, $8A, $28, $89, $28, $94, $28, $28, $27, $89, $27, $8A, $27, $89
        .byte $27, $94, $27, $27, $25, $89, $25, $8A, $25, $89, $25, $94, $25, $24, $E8, $60
        .byte $B3, $E0, $11, $E3, $05, $EB, $02, $EB, $03, $94, $01, $89, $01, $8A, $01, $89
        .byte $01, $94, $01, $01, $EC, $94, $01, $EB, $03, $89, $01, $8A, $01, $89, $01, $EC
        .byte $EC, $EB, $04, $94, $01, $89, $01, $8A, $01, $89, $01, $94, $01, $01, $EC, $E8
        .byte $AC, $B3, $EB, $02, $EB, $03, $FB, $0F, $F0, $10, $94, $0C, $FB, $0F, $F0, $10
        .byte $89, $0C, $FB, $0F, $F0, $10, $8A, $0C, $FB, $0F, $F0, $10, $89, $0C, $FB, $0F
        .byte $F0, $10, $94, $0C, $FB, $0F, $F0, $10, $0C, $EC, $FB, $0F, $F0, $10, $94, $0C
        .byte $EB, $03, $FB, $0F, $F0, $10, $89, $0C, $FB, $0F, $F0, $10, $8A, $0C, $FB, $0F
        .byte $F0, $10, $89, $0C, $EC, $EC, $EB, $04, $FB, $0F, $F0, $10, $94, $0C, $FB, $0F
        .byte $F0, $10, $89, $0C, $FB, $0F, $F0, $10, $8A, $0C, $FB, $0F, $F0, $10, $89, $0C
        .byte $EB, $02, $FB, $0F, $F0, $10, $94, $0C, $EC, $EC, $E8, $D9, $B3
sound_4D:
        .byte $04, $54, $B4, $05, $CD, $B4, $02, $1D, $B5, $07, $27, $B5, $06, $42, $B5, $FF
        .byte $E0, $05, $E2, $80, $E3, $0A, $8F, $2A, $26, $30, $ED, $30, $93, $30, $E0, $04
        .byte $30, $ED, $E0, $05, $8F, $31, $ED, $31, $EF, $2A, $30, $ED, $30, $93, $30, $30
        .byte $E0, $04, $8F, $30, $EF, $E0, $05, $98, $0C, $E3, $0B, $EB, $02, $8A, $2A, $26
        .byte $30, $ED, $30, $30, $E0, $04, $30, $E0, $05, $EF, $0C, $31, $ED, $E0, $04, $31
        .byte $EF, $E0, $05, $2A, $30, $30, $ED, $30, $30, $E0, $04, $30, $E0, $05, $0C, $EF
        .byte $EC, $EB, $02, $31, $2A, $33, $ED, $33, $33, $E0, $04, $33, $EF, $0C, $E0, $05
        .byte $34, $ED, $E0, $04, $34, $EF, $E0, $05, $31, $33, $33, $ED, $33, $33, $E0, $04
        .byte $33, $EF, $0C, $E0, $05, $EC, $E8, $7F, $B4, $E0, $05, $E2, $80, $E3, $0B, $8F
        .byte $23, $23, $23, $23, $93, $23, $E0, $04, $23, $E0, $05, $8F, $23, $23, $23, $23
        .byte $23, $23, $93, $23, $E0, $04, $93, $23, $98, $0C, $EB, $02, $90, $23, $8A, $0C
        .byte $90, $23, $8A, $1A, $90, $21, $23, $8A, $0C, $90, $23, $8A, $25, $90, $26, $EC
        .byte $EB, $02, $90, $26, $8A, $0C, $90, $26, $8A, $21, $90, $24, $26, $8A, $0C, $90
        .byte $26, $8A, $28, $90, $29, $EC, $E8, $EE, $B4, $E0, $0E, $A6, $0C, $0C, $98, $0C
        .byte $E8, $EE, $B4, $E3, $05, $81, $00, $83, $10, $97, $10, $A6, $10, $10, $E0, $11
        .byte $8A, $01, $01, $01, $01, $01, $01, $01, $E0, $09, $01, $E8, $32, $B5, $A6, $0C
        .byte $0C, $FB, $0F, $F4, $20, $85, $0C, $FB, $0F, $F4, $20, $0C, $0C, $FB, $0F, $F4
        .byte $20, $0C, $EB, $02, $FB, $0F, $F4, $20, $0C, $0C, $EC, $FB, $0F, $F0, $10, $90
        .byte $0C, $FB, $0F, $F4, $20, $8A, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F0, $10
        .byte $90, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20
        .byte $8A, $0C, $EB, $02, $FB, $0F, $F0, $10, $0C, $EC, $EB, $03, $FB, $0F, $F4, $20
        .byte $0C, $EC, $E8, $5F, $B5
sound_4E:
        .byte $04, $A9, $B5, $05, $19, $B6, $02, $43, $88, $07, $43, $88, $06, $43, $88, $FF
        .byte $E2, $80, $E3, $0A, $E9, $FA, $B5, $E0, $05, $92, $27, $ED, $9A, $27, $E0, $04
        .byte $27, $E9, $FA, $B5, $E0, $05, $92, $26, $ED, $26, $E0, $04, $26, $EF, $E0, $05
        .byte $8F, $28, $ED, $E0, $04, $95, $28, $EF, $E0, $05, $8F, $25, $ED, $E0, $04, $95
        .byte $25, $EF, $E0, $05, $8F, $26, $ED, $E0, $04, $95, $26, $EF, $E0, $05, $8F, $27
        .byte $E0, $04, $95, $27, $EF, $E0, $05, $9A, $28, $ED, $A2, $28, $E0, $04, $9A, $28
        .byte $FF, $E0, $05, $84, $35, $ED, $E0, $04, $90, $35, $EF, $E0, $05, $84, $32, $ED
        .byte $E0, $04, $90, $32, $EF, $E0, $05, $84, $2A, $ED, $E0, $04, $90, $2A, $EF, $EA
        .byte $E0, $05, $E2, $80, $E3, $0A, $A2, $23, $E0, $04, $92, $23, $25, $27, $2A, $E0
        .byte $05, $A2, $20, $E0, $04, $92, $0C, $1A, $20, $17, $E0, $05, $E3, $0B, $9A, $15
        .byte $16, $17, $18, $18, $18, $E0, $04, $18, $FF
snd_star:
        .byte $03, $46, $B6, $FF, $E0, $11, $81, $10, $E3, $00, $81, $04, $0C, $0A, $FF
sound_10:
        .byte $03, $55, $B6, $FF, $E0, $11, $81, $10, $E3, $00, $81, $0C, $0A, $08, $06, $FF
snd_hurt:
        .byte $01, $68, $B6, $03, $93, $B6, $FF, $F9, $E0, $00, $81, $0C, $E2, $80, $0C, $E3
        .byte $05, $0C, $15, $13, $14, $12, $13, $11, $12, $10, $11, $0B, $10, $0A, $0B, $09
        .byte $0A, $08, $09, $07, $08, $06, $07, $05, $06, $04, $05, $03, $04, $02, $03, $01
        .byte $F8, $FF, $81, $10, $E0, $00, $10, $E3, $03, $10, $81, $0C, $0B, $E3, $01, $0B
        .byte $0A, $E3, $02, $0A, $09, $E3, $03, $09, $08, $E3, $04, $08, $07, $E3, $05, $07
        .byte $06, $E3, $06, $06, $05, $E3, $07, $05, $04, $E3, $08, $04, $03, $E3, $09, $03
        .byte $02, $E3, $0A, $02, $01, $E3, $0B, $01, $00, $FF
snd_enemy_dies:
        .byte $01, $D2, $B6, $03, $E6, $B6, $FF, $F9, $E0, $09, $82, $0C, $E2, $80, $82, $0C
        .byte $E3, $00, $81, $10, $00, $11, $01, $10, $00, $F8, $FF, $81, $10, $E0, $09, $82
        .byte $10, $E3, $00, $81, $10, $82, $05, $83, $0E, $0D, $8E, $09, $FF
snd_pickup:
        .byte $00, $FF, $B6, $01, $29, $B7, $FF, $F9, $E0, $00, $81, $0C, $E2, $80, $0C, $E3
        .byte $07, $0C, $81, $48, $49, $44, $45, $40, $41, $38, $39, $34, $35, $30, $31, $28
        .byte $29, $24, $25, $20, $21, $31, $30, $35, $34, $39, $38, $40, $43, $46, $49, $F8
        .byte $FF, $83, $0C, $E0, $00, $0C, $E2, $50, $0C, $E3, $0C, $0C, $E8, $0A, $B7
snd_one_up:
        .byte $00, $3E, $B7, $01, $63, $B7, $FF, $F9, $E0, $00, $81, $0C, $E2, $80, $0C, $E3
        .byte $07, $0C, $82, $E4, $86, $20, $E4, $86, $24, $E4, $86, $27, $E4, $86, $30, $E4
        .byte $86, $34, $E4, $86, $37, $E4, $86, $39, $8C, $40, $F8, $FF, $83, $0C, $E5, $01
        .byte $82, $0C, $E8, $3E, $B7
; Health, or a lantern breaking.
sound_15:
        .byte $00, $73, $B7, $01, $A6, $B7, $FF, $F9, $E0, $00, $81, $0C, $E2, $80, $0C, $E3
        .byte $07, $0C, $81, $10, $11, $14, $15, $18, $19, $20, $21, $24, $25, $28, $29, $30
        .byte $31, $34, $35, $38, $39, $40, $41, $44, $45, $48, $49, $50, $51, $54, $55, $58
        .byte $59, $60, $61, $64, $65, $68, $89, $69, $F8, $FF, $83, $0C, $E0, $00, $83, $0C
        .byte $E2, $80, $0C, $E3, $0C, $0C, $E8, $7E, $B7
; While the Invincible Fire-Wheel burns.
sound_16:
        .byte $01, $B9, $B7, $FF, $81, $0C, $E0, $00, $E2, $40, $0C, $E3, $03, $81, $37, $40
        .byte $0C, $37, $40, $0C, $37, $40, $FF
snd_jump:
        .byte $03, $D0, $B7, $FF, $81, $10, $E0, $00, $E3, $00, $81, $03, $09, $02, $FF
snd_windmill:
        .byte $03, $DF, $B7, $FF, $81, $10, $E0, $00, $E3, $03, $81, $02, $04, $06, $08, $01
        .byte $03, $05, $07, $82, $10, $E8, $E5, $B7
snd_fire_wheel:
        .byte $03, $F7, $B7, $FF, $81, $10, $E0, $00, $E3, $00, $81, $10, $E9, $05, $B8, $96
        .byte $0F, $FF, $81, $00, $01, $02, $03, $04, $05, $04, $05, $06, $05, $06, $07, $06
        .byte $07, $08, $07, $08, $09, $08, $09, $0A, $09, $0A, $0B, $0A, $0B, $0C, $0B, $0C
        .byte $0D, $0C, $0D, $0E, $0D, $0E, $EA
; The spinning sword, the stone man's ring, and the Masked Devil calling fireballs.
sound_1A:
        .byte $03, $2E, $B8, $FF, $81, $10, $E0, $00, $E3, $00, $81, $08, $09, $0A, $0B, $0F
        .byte $0E, $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $04, $03, $02, $03
        .byte $02, $01, $02, $01, $96, $00, $FF
snd_beep:
        .byte $01, $55, $B8, $FF, $81, $0C, $E0, $05, $E2, $80, $0C, $E3, $00, $83, $2B, $82
        .byte $0C, $83, $2B, $FF
; Bomberhead's sickle, and the last boss's fireballs.
sound_1C:
        .byte $01, $6C, $B8, $03, $A0, $B8, $FF, $81, $0C, $E0, $00, $E2, $40, $81, $0C, $E3
        .byte $07, $81, $00, $10, $20, $01, $11, $21, $03, $13, $23, $05, $15, $25, $24, $22
        .byte $14, $12, $23, $21, $13, $11, $22, $20, $12, $10, $0B, $0A, $09, $08, $07, $06
        .byte $05, $04, $03, $02, $01, $00, $84, $0C, $E8, $76, $B8, $82, $10, $E0, $00, $10
        .byte $E3, $05, $10, $E9, $05, $B8, $81, $0F, $84, $10, $E8, $A8, $B8
sound_1D:
        .byte $01, $B9, $B8, $03, $D8, $B8, $FF, $F9, $81, $0C, $E0, $00, $E2, $C0, $0C, $E3
        .byte $00, $01, $00, $04, $03, $0C, $0C, $10, $0B, $0A, $09, $08, $07, $06, $05, $04
        .byte $03, $02, $01, $00, $F8, $FF, $81, $10, $E0, $00, $10, $E3, $08, $00, $02, $04
        .byte $06, $01, $02, $03, $04, $82, $05, $06, $83, $07, $8E, $0C, $FF
snd_lightning:
        .byte $07, $F3, $B8, $FF, $81, $0C, $E0, $00, $E3, $00, $84, $0E, $0F, $0D, $0E, $0C
        .byte $0D, $E3, $01, $0B, $0C, $0A, $0B, $E3, $02, $09, $0A, $08, $09, $E3, $03, $07
        .byte $08, $E3, $04, $06, $07, $E3, $05, $05, $06, $E3, $06, $04, $05, $E0, $06, $9C
        .byte $04, $FF
snd_gun:
        .byte $01, $28, $B9, $03, $3A, $B9, $FF, $81, $0C, $E0, $11, $E2, $00, $0C, $E3, $04
        .byte $EB, $06, $81, $00, $12, $82, $0C, $EC, $FF, $81, $10, $E0, $11, $10, $E3, $08
        .byte $EB, $06, $81, $0C, $04, $82, $10, $EC, $FF
; Jaquio fires.
sound_0E:
        .byte $03, $4E, $B9, $FF, $81, $10, $E0, $00, $E3, $00, $81, $0A, $0B, $0C, $0D, $0C
        .byte $0B, $0A, $09, $08, $FF
snd_crouch_shot:
        .byte $01, $66, $B9, $03, $81, $B9, $FF, $81, $0C, $E0, $00, $E2, $40, $0C, $E3, $00
        .byte $84, $E4, $85, $10, $E3, $05, $E4, $85, $0B, $E3, $0A, $E4, $85, $0A, $E4, $85
        .byte $09, $FF, $81, $10, $E0, $00, $81, $10, $E3, $03, $0F, $05, $0E, $05, $0D, $05
        .byte $06, $07, $08, $09, $E3, $06, $8E, $07, $FF
sound_22:
        .byte $04, $A8, $B9, $05, $D2, $B9, $02, $FB, $B9, $07, $05, $BA, $06, $43, $88, $FF
        .byte $E2, $80, $84, $0C, $E3, $00, $0C, $E0, $00, $81, $0C, $86, $E4, $85, $15, $FF
        .byte $E3, $05, $E4, $85, $14, $E3, $0A, $E4, $85, $13, $E4, $85, $12, $E4, $85, $11
        .byte $E4, $85, $10, $E4, $85, $0B, $E4, $85, $0A, $FF, $81, $0C, $E2, $C0, $84, $0C
        .byte $E3, $00, $8A, $0C, $E0, $06, $E4, $85, $18, $E3, $05, $E4, $85, $17, $E3, $0A
        .byte $E4, $85, $18, $E4, $85, $17, $E4, $85, $16, $E4, $85, $17, $E4, $85, $16, $E4
        .byte $85, $15, $FF, $82, $0C, $E0, $0C, $86, $0C, $ED, $96, $07, $FF, $83, $10, $E3
        .byte $00, $10, $82, $10, $E3, $00, $E0, $06, $81, $0F, $05, $0E, $05, $0D, $05, $06
        .byte $07, $08, $09, $EB, $0F, $0F, $05, $0E, $05, $0D, $05, $06, $07, $08, $09, $EC
        .byte $0A, $0B, $0C, $0B, $0C, $0D, $0C, $0D, $0E, $A5, $0D, $FF
snd_lose_life:
        .byte $01, $43, $88, $03, $43, $88, $06, $43, $88, $04, $4A, $BA, $05, $67, $BA, $02
        .byte $82, $BA, $07, $98, $BA, $FF, $81, $0C, $E0, $04, $E2, $80, $E3, $09, $ED, $8B
        .byte $38, $37, $35, $2A, $2A, $92, $38, $8B, $37, $38, $35, $92, $37, $8B, $34, $38
        .byte $9A, $35, $FF, $97, $0C, $E0, $04, $E2, $40, $E3, $0A, $81, $0C, $8B, $25, $25
        .byte $92, $35, $8B, $33, $35, $30, $92, $30, $8B, $30, $35, $9A, $30, $FF, $81, $0C
        .byte $E0, $0D, $97, $0C, $8B, $1A, $1A, $0C, $21, $0C, $20, $30, $20, $0C, $23, $24
        .byte $E0, $0C, $25, $FF, $81, $10, $E0, $11, $E3, $05, $8B, $01, $02, $03, $EB, $02
        .byte $FB, $0F, $F0, $10, $8B, $01, $EC, $FB, $0F, $F4, $20, $02, $01, $FB, $0F, $F0
        .byte $10, $01, $EB, $02, $FB, $0F, $F4, $20, $01, $EC, $FB, $0F, $F0, $10, $01, $10
        .byte $EB, $03, $FB, $0F, $F4, $20, $01, $EC, $FF
snd_start:
        .byte $01, $E3, $BA, $02, $43, $88, $03, $43, $88, $04, $43, $88, $05, $43, $88, $06
        .byte $43, $88, $07, $43, $88, $FF, $81, $0C, $E0, $00, $0C, $E2, $80, $0C, $E3, $00
        .byte $83, $39, $37, $0C, $85, $40, $FF
sound_38:
        .byte $03, $F8, $BA, $FF, $E0, $11, $E3, $00, $81, $0F, $0E, $0D, $8A, $0A, $FF
sound_36:
        .byte $01, $0A, $BB, $03, $1A, $BB, $FF, $E0, $00, $E2, $80, $83, $0C, $0C, $E3, $0C
        .byte $81, $45, $E3, $00, $96, $5B, $FF, $E0, $00, $E3, $00, $82, $04, $05, $04, $05
        .byte $83, $04, $03, $84, $02, $FF
sound_37:
        .byte $03, $2D, $BB, $FF, $E0, $00, $E3, $01, $81, $0A, $EB, $10, $06, $0B, $E3, $07
        .byte $07, $02, $05, $10, $10, $EC, $FF
snd_sword:
        .byte $03, $44, $BB, $FF, $E0, $00, $E3, $00, $81, $0A, $08, $82, $06, $04, $83, $01
        .byte $FF
sound_3D:
        .byte $03, $55, $BB, $FF, $E0, $00, $E3, $05, $ED, $84, $09, $85, $05, $FF
sound_39:
        .byte $01, $66, $BB, $03, $73, $BB, $FF, $E0, $00, $E2, $80, $E3, $00, $81, $09, $0A
        .byte $0B, $0A, $14, $FF, $E0, $11, $E3, $00, $81, $0F, $0E, $0D, $E3, $03, $8A, $0A
        .byte $FF
sound_3B:
        .byte $00, $43, $88, $01, $99, $BB, $02, $43, $88, $03, $9E, $BB, $04, $43, $88, $05
        .byte $43, $88, $06, $43, $88, $07, $43, $88, $FF, $81, $0C, $E8, $D2, $B6, $E0, $00
        .byte $E3, $00, $81, $10, $0C, $04, $96, $0B, $FF
sound_3E:
        .byte $04, $B9, $BB, $05, $CC, $BB, $07, $D8, $BB, $02, $43, $88, $06, $43, $88, $FF
        .byte $E0, $05, $E2, $00, $E3, $06, $90, $0A, $E5, $06, $0A, $E5, $0B, $0A, $E5, $03
        .byte $E8, $C0, $BB, $E0, $05, $E2, $80, $E3, $06, $ED, $90, $04, $E8, $D3, $BB, $E0
        .byte $00, $E3, $09, $81, $0D, $82, $03, $E8, $DC, $BB
snd_hit:
        .byte $01, $EA, $BB, $03, $F6, $BB, $FF, $E0, $05, $E2, $C0, $E3, $00, $81, $01, $00
        .byte $00, $01, $FF, $E0, $00, $E3, $00, $82, $10, $81, $01, $0F, $0D, $0E, $0D, $83
        .byte $0F, $FF
snd_boss_explode:
        .byte $04, $43, $88, $05, $43, $88, $02, $43, $88, $07, $0C, $BA, $06, $43, $88, $03
        .byte $43, $88, $FF
; Basaquer and Kelbeross.
sound_41:
        .byte $00, $1F, $BC, $03, $30, $BC, $FF, $E3, $00, $86, $E4, $85, $15, $E3, $05, $E4
        .byte $85, $14, $E3, $0A, $E4, $85, $13, $FF, $E0, $06, $E3, $03, $81, $0F, $05, $0E
        .byte $05, $0D, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0B, $0C, $0D, $0C, $0D, $0E
        .byte $96, $0C, $FF
sound_42:
        .byte $04, $43, $88, $05, $43, $88, $02, $43, $88, $07, $5B, $BC, $06, $43, $88, $FF
        .byte $E0, $05, $E3, $02, $86, $00, $00, $01, $01, $02, $02, $03, $03, $85, $04, $04
        .byte $05, $05, $84, $06, $06, $07, $07, $83, $08, $08, $FF
sound_43:
        .byte $04, $86, $BC, $05, $21, $BD, $06, $C4, $BD, $07, $CD, $BD, $02, $43, $88, $FF
        .byte $E0, $00, $E2, $80, $E3, $0C, $81, $00, $E3, $0B, $00, $E3, $0A, $00, $E3, $09
        .byte $00, $E3, $08, $00, $E3, $07, $00, $E3, $06, $00, $E3, $05, $00, $E9, $CD, $BC
        .byte $E9, $CD, $BC, $E9, $CD, $BC, $E9, $CD, $BC, $E9, $CD, $BC, $E9, $CD, $BC, $E9
        .byte $CD, $BC, $E9, $CD, $BC, $E9, $CD, $BC, $E9, $CD, $BC, $FE, $38, $E9, $CD, $BC
        .byte $E9, $CD, $BC, $E9, $CD, $BC, $FF, $81, $E9, $FC, $BC, $15, $06, $11, $83, $10
        .byte $81, $10, $05, $09, $06, $E9, $FC, $BC, $05, $06, $07, $06, $05, $04, $05, $06
        .byte $07, $06, $05, $04, $E9, $FC, $BC, $05, $04, $05, $04, $05, $04, $E9, $FC, $BC
        .byte $82, $10, $06, $15, $08, $EA, $15, $11, $10, $06, $14, $10, $09, $05, $13, $09
        .byte $08, $04, $12, $08, $07, $03, $11, $07, $06, $02, $10, $06, $05, $01, $09, $05
        .byte $00, $04, $09, $05, $04, $00, $09, $05, $00, $04, $EA, $E0, $00, $E2, $80, $E3
        .byte $0C, $81, $01, $E3, $0B, $01, $E3, $0A, $01, $E3, $09, $01, $E3, $08, $01, $E3
        .byte $07, $01, $E3, $06, $01, $E3, $05, $01, $E9, $59, $BD, $E9, $59, $BD, $E9, $59
        .byte $BD, $E9, $59, $BD, $E9, $59, $BD, $E9, $59, $BD, $FE, $20, $E9, $59, $BD, $E9
        .byte $59, $BD, $FF, $81, $E9, $9F, $BD, $10, $05, $08, $11, $06, $09, $09, $04, $12
        .byte $E9, $9F, $BD, $82, $00, $01, $02, $E9, $9F, $BD, $81, $12, $09, $15, $82, $0B
        .byte $81, $06, $08, $04, $E9, $9F, $BD, $06, $05, $03, $04, $04, $03, $05, $82, $E9
        .byte $9F, $BD, $81, $07, $06, $08, $09, $08, $07, $08, $09, $08, $07, $E9, $9F, $BD
        .byte $00, $05, $00, $00, $05, $00, $00, $05, $EA, $10, $09, $08, $07, $06, $09, $08
        .byte $07, $06, $05, $08, $07, $06, $05, $04, $07, $06, $05, $04, $03, $06, $05, $04
        .byte $03, $06, $05, $03, $04, $06, $05, $04, $03, $06, $05, $03, $04, $EA, $E0, $0C
        .byte $ED, $EB, $21, $9D, $15, $EC, $FF, $E0, $0F, $E3, $0D, $81, $0A, $E3, $0C, $0A
        .byte $E3, $0B, $0A, $E3, $0A, $0A, $E3, $09, $0A, $E3, $08, $0A, $E3, $07, $0A, $E3
        .byte $06, $0A, $EB, $0A, $90, $0A, $98, $0A, $9D, $0A, $90, $0A, $98, $0A, $EC, $FE
        .byte $60, $EB, $20, $90, $0A, $EC, $FF, $04, $0D, $BE, $05, $21, $BE, $02, $43, $88
        .byte $06, $43, $88, $07, $35, $BE, $FF, $E0, $06, $E2, $80, $E3, $00, $84, $E4, $83
        .byte $30, $FE, $05, $EB, $08, $8B, $E4, $83, $30, $EC, $FF, $E0, $06, $E2, $80, $E3
        .byte $01, $84, $E4, $83, $27, $FE, $05, $EB, $08, $8B, $E4, $83, $27, $EC, $FF, $E0
        .byte $09, $E3, $00, $84, $06, $FE, $05, $EB, $08, $8B, $06, $EC, $FF, $FF
sound_46:
        .byte $02, $48, $BE, $FF, $E0, $0C, $84, $48, $0C, $8A, $48, $84, $0C, $8D, $48, $92
        .byte $0C, $84, $48, $0C, $8A, $48, $84, $0C, $8D, $48, $FF
sound_47:
        .byte $04, $6F, $BE, $05, $96, $BE, $02, $C6, $BE, $07, $EB, $BE, $06, $17, $BF, $FF
        .byte $E0, $04, $E2, $40, $E3, $0A, $ED, $A2, $0C, $E9, $FC, $96, $E9, $49, $97, $E9
        .byte $FC, $96, $E9, $49, $97, $E9, $FC, $96, $8B, $24, $0C, $26, $26, $24, $26, $0C
        .byte $EF, $29, $ED, $28, $92, $26, $FF, $E0, $00, $E2, $00, $E3, $09, $A2, $0C, $E9
        .byte $06, $98, $8B, $0C, $0C, $EB, $04, $E9, $32, $98, $8B, $29, $28, $26, $0C, $EC
        .byte $E9, $06, $98, $8B, $0C, $0C, $EB, $04, $E9, $32, $98, $8B, $29, $28, $26, $0C
        .byte $EC, $E9, $06, $98, $E8, $87, $BE, $E0, $10, $EB, $04, $8B, $11, $21, $EC, $E9
        .byte $81, $98, $E9, $B3, $98, $E9, $81, $98, $E9, $B3, $98, $E9, $81, $98, $8B, $24
        .byte $0C, $26, $26, $24, $26, $0C, $29, $28, $E0, $0C, $26, $FF, $E0, $11, $E3, $05
        .byte $EB, $02, $8B, $01, $86, $01, $01, $01, $01, $01, $01, $EC, $E9, $F7, $98, $E9
        .byte $28, $99, $E9, $F7, $98, $E9, $28, $99, $E9, $F7, $98, $8B, $01, $EB, $0A, $86
        .byte $01, $EC, $8B, $10, $01, $01, $01, $FF, $EB, $02, $FB, $0F, $F0, $10, $92, $0C
        .byte $FB, $0F, $F4, $20, $0C, $EC, $E9, $62, $99, $E9, $62, $99, $E9, $8B, $99, $E9
        .byte $B2, $99, $E9, $B2, $99, $E9, $B2, $99, $E9, $B2, $99, $E9, $62, $99, $E9, $62
        .byte $99, $E9, $8B, $99, $E9, $B2, $99, $E9, $B2, $99, $E9, $B2, $99, $E9, $B2, $99
        .byte $E9, $62, $99, $E9, $62, $99, $E9, $8B, $99, $EB, $02, $FB, $0F, $F0, $10, $8B
        .byte $0C, $FB, $0F, $F4, $20, $0C, $EC, $0C, $EB, $03, $FB, $0F, $F4, $20, $0C, $EC
        .byte $FF
sound_01:
        .byte $01, $77, $BF, $03, $78, $BF, $FF, $FF, $FF, $09, $ED, $8F, $0C, $19, $20, $22
        .byte $24, $8B, $25, $27, $EF, $8F, $29, $FF, $E0, $0D, $8F, $0C, $22, $20, $19, $20
        .byte $8B, $19, $24, $E0, $0C, $22, $FF, $E0, $11, $E3, $05, $86, $00, $01, $02, $EB
        .byte $02, $FB, $0F, $F0, $10, $8B, $01, $EC, $02, $FB, $0F, $F4, $20, $01, $FB, $0F
        .byte $F0, $10, $01, $EB, $04, $FB, $0F, $F4, $20, $02, $EC, $FF, $04, $CC, $BF, $05
        .byte $30, $C0, $02, $3C, $C0, $07, $61, $C0, $06, $76, $C0, $FF, $E0, $00, $E2, $40
        .byte $E3, $09, $E5, $01, $87, $33, $0C, $33, $0C, $30

; --- $BFDA  Same first instructions as reset.
reset_copy_03:
        inc $FFDA
        jmp $C03E
        .res 26, $FF
        .byte $DA, $FF, $DA, $FF, $DA, $FF
