; PRG file bank 07, fixed at $C000-$FFFF.
; MMC1 control $1E (see reset): vertical mirroring, 16 KiB PRG with this
; bank fixed, CHR switched as two 4 KiB banks.
;
; MMC1 serial writes are LSB first, five stores, bit 0 of each store.
; $9FFF control, $BFFF CHR bank 0 ($0000), $DFFF CHR bank 1 ($1000),
; $FFFF PRG bank ($8000).

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014
SNDCHN    = $4015
JOY1      = $4016

MMC1_CTRL = $9FFF
MMC1_CHR0 = $BFFF
MMC1_CHR1 = $DFFF
MMC1_PRG  = $FFFF

ppuctrl_shadow = $1C
ppumask_shadow = $1D
nmi_latch      = $1F
pad_cur        = $28
pad_edge       = $29
from_right     = $3D   ; bit 7, this room starts at its right end
ground_ptr     = $40   ; this room's ground
ground_ptr_hi  = $41
scroll_flags   = $4C   ; bit 7 the last column came from the left. Bit 6 a column is waiting, so enemies wait. Bit 0 flips each screen of fine scroll.
screen_col     = $4E   ; column at the left of the screen. Each column is 16 pixels.
screen_right   = $4F   ; column at the right edge, one screen on
scroll_frac    = $50   ; fraction under the stage scroll
stage_x        = $51   ; how far the stage has scrolled
stage_x_hi     = $52   ; the high byte. One per screen.
scroll_pages   = $53   ; how many screens this room scrolls
ground_i       = $5F   ; where this column starts in the ground map
room           = $6E   ; which room
room_back      = $6F   ; bit 7, he entered by going back to the previous room
packet         = $2B   ; screen update pointer; the high byte is the next address
picture_at     = $E4   ; where a picture is drawn
picture_at_hi  = $E5   ; the high byte of that place
status_i       = $3E   ; which status field is redrawn this frame
timer          = $63
frames         = $62   ; counts down to the next second
nmi_count      = $BF   ; counts up every frame
ninpo          = $64
health         = $65
score          = $60
score_hi       = $61
sound          = $0600 ; which sound to play
area           = $6D
lives          = $76
prg_bank       = $5C
action         = $80   ; what Ryu is doing
pose           = $83   ; which frame of that action he is on
ryu_flags      = $84   ; bit 6 faces left, bit 2 is in the air
ryu_x_frac     = $85
ryu_x          = $86
height_frac    = $87
speed_y        = $89
height         = $8A
touching       = $8C   ; walls and steps he is against
speed_x_frac   = $AC
speed_x        = $AD
enemy_bits     = $73   ; which enemy slots are occupied
lantern_bits   = $C0   ; which lantern slots are occupied
thrown         = $C8   ; which thrown weapons are out
weapon         = $C9   ; the weapon he has equipped
hourglass_on   = $D0
ryu_step       = $81   ; where he is in this action's pictures
ryu_delay      = $82   ; frames left on this picture
flicker        = $8D   ; flips each frame while he is hurt, and hides him on half of them
downed         = $8B   ; bit 7 he fell, bit 6 his health is gone
sprite_slot    = $3B   ; next sprite to draw. Sprite 0 is the status split
knockback      = $93   ; bit 7 he is knocked back
hurt_time      = $95   ; frames left in the knockback
enemy_flags    = $79   ; this turn. Bit 6 walks, bit 7 flies, bit 2 is in the air, bit 4 is dying, bit 0 is a boss
facing         = $7A   ; this turn. Bit 6 faces left
boss_hp        = $66
enemy_count    = $72   ; how many enemies are on screen
enemy_type     = $0400
enemy_timer    = $0408
enemy_state    = $0410
enemy_delay    = $0420 ; frames left on this picture
enemy_action   = $0428
enemy_step     = $0430
enemy_pose     = $0438
slot_facing    = $0440 ; saved copy of facing
enemy_x_frac   = $0448
enemy_x_spd    = $0450
enemy_x_sub    = $0458
enemy_x        = $0460
enemy_y_frac   = $0468
enemy_y_spd    = $0470
enemy_y_sub    = $0478
enemy_y        = $0480
enemy_touch    = $0488 ; floor and walls he is touching
enemy_hp       = $0490
slot_flags     = $0498 ; saved copy of enemy_flags

; --- $C000  A = CHR bank 0 ------------------------------------------------
set_chr0:
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        rts

; --- $C014  A = CHR bank 1 ------------------------------------------------
set_chr1:
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        rts

; --- $C028  A = PRG bank at $8000, shadowed in prg_bank -------------------
set_prg:
        sta prg_bank
        sta MMC1_PRG
        lsr
        sta MMC1_PRG
        lsr
        sta MMC1_PRG
        lsr
        sta MMC1_PRG
        lsr
        sta MMC1_PRG
        rts

; --- $C03E  reset ----------------------------------------------------------
; Two PPU warm-up frames, then MMC1 control $1E:
;   mirroring = vertical, PRG = 16 KiB with bank 07 fixed at $C000,
;   CHR = 4 KiB + 4 KiB.
reset:
        sei
        cld
@warmup1:
        bit PPUSTATUS
        bpl @warmup1
@warmup2:
        bit PPUSTATUS
        bpl @warmup2
        ldx #$FF
        txs
        inx                     ; X = 0, first control bit
        stx MMC1_CTRL           ; bits 0,1,1,1,1 -> control $1E
        inx
        stx MMC1_CTRL
        stx MMC1_CTRL
        stx MMC1_CTRL
        stx MMC1_CTRL
        dex
        stx SNDCHN              ; silence APU
        lda #$07                ; clear $0000-$07FF
        sta $01
        lda #$00
        sta $00
        tay
@clear:
        sta ($00),y
        dey
        bne @clear
        dec $01
        bpl @clear
        lda #$1E                ; sprites + background on
        sta ppumask_shadow
        sta PPUMASK
        lda #$B0                ; NMI on, 8x16 sprites, BG pattern $1000
        sta ppuctrl_shadow
        sta PPUCTRL
        jsr boot_banks          ; does not return; jumps to reset_cont
reset_cont:
        jsr wait_nmi
        lda scroll_flags
        and #$BF                ; the waiting column has been drawn
        sta scroll_flags
        jsr sprite0_split
        lda pad_edge
        bit $1E
        bmi @flag_was_set
        cmp #$10
        bne @continue
        lda #$24
        sta sound
        lda #$80
        sta $1E
        bmi @continue           ; always
@flag_was_set:
        cmp #$10
        bne @finish
        lda #$00
        sta $1E
        lda #$00
        jsr set_prg             ; bank 0 at $8000
        ldx area
        lda $AFC6,x             ; table in the bank at $8000
        sta sound
@continue:
        jsr player_control
        jsr scroll_stage
        bit scroll_flags
        bvs @skip_intro         ; a column is waiting, so enemies wait
        jsr tick_clock
        jsr spawn_enemies
        jsr run_enemies
@skip_intro:
        jsr move_lanterns
        jsr spawn_lanterns
        jsr move_weapon
        nop
        nop
        nop
@finish:
        jsr draw_all
        jmp frame_gate

; --- $C0E0  three ways out of the play loop --------------------------------
to_hold:
        jmp hold_loop
to_area_event:
        jmp area_event
to_play:
        jmp reset_cont

; --- $C0E9  hidden stage select. The game never calls this.
; Up, A, B, and Start opens the sound test. Pick 0 to leave it.
; Then pick the stage.
pick_area:
        lda #$10
        sta $59
        lda #$00
        jsr show_screen
        jsr wait_nmi
        lda pad_cur
        cmp #$D8                        ; Up, Start, A, and B
        bne pick_stage
        lda #$00
        sta $01
        lda #$04
        jsr show_screen
; --- $C104  Keep playing that sound until the number is 0.
test_sound:
        lda $01
        jsr edit_number
        sta $01
        sta sound                       ; play that sound
        bne test_sound
; --- $C110  Those buttons were not held. Pick the stage.
pick_stage:
        lda #$03
        jsr show_screen
        jsr pick_number
        sta area
        lda #$10
        sta $5A
        jsr blank_palette
        jmp wait_nmi

; --- $C124  show a number as two digits
; A and Right add one, A and Left subtract one, Start confirms.
pick_number:
        lda #$00
edit_number:
        sta $00
; --- $C128  Draw the number, and see which buttons are held.
redraw_number:
        ldx #$05
; --- $C12A  A few frames between reads.
number_wait:
        jsr wait_nmi
        dex
        bne number_wait
        lda #$02
        sta $0700
        lda #$92
        sta $0701
        lda #$21
        sta $0702
        lda #$00
        sta $0705
        lda $00
        lsr
        lsr
        lsr
        lsr
        tax
        lda digit_tiles,x
        sta $0703
        lda $00
        and #$0F
        tax
        lda digit_tiles,x
        sta $0704
        lda #$00
        sta packet
        lda #$07
        sta packet+1
        lda pad_cur
        and #$93
        cmp #$81                        ; A and Right
        beq digit_inc
        cmp #$82                        ; A and Left
        beq digit_dec
        cmp #$10                        ; Start
        bne redraw_number
; --- $C174  Start was pressed. Wait until the buttons are up.
release_pad:
        lda pad_cur
        bne release_pad
        lda $00
        rts
; --- $C17B  Add one.
digit_inc:
        inc $00                         ; add one
        jmp redraw_number
; --- $C180  Subtract one.
digit_dec:
        dec $00                         ; subtract one
        jmp redraw_number

; --- $C185  tiles for the digits 0-9 and A-F
digit_tiles:
        .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $A0, $A1, $A2, $A3, $A4, $A5

; --- $C195  one entry per enemy, including the shots they fire
; Each entry is that enemy's actions. $FFFF is an unused number.
actor_kind:
        .word boxer
        .word machine_gunner
        .word thrower
        .word batter
        .word knife_thrower
        .word crouching_soldier
        .word jump_kicker
        .word running_soldier
        .word bat
        .word attacking_dog
        .word waiting_dog
        .word bird
        .word jetpack_ninja
        .word running_ninja
        .word stone_man
        .word crouched_ghoul
        .word waiting_ghoul
        .word machine_gun_bullet
        .word axe
        .word knife
        .word crouching_soldier_bullet
        .word shuriken
        .word stone_man_ring
        .word barbarian
        .word bomberhead
        .word basaquer
        .word basaquer_shot
        .word kelbeross
        .word kelbeross_fireball
        .word $FFFF
        .word bloody_malth
        .word bloody_malth_lightning
        .word $FFFF
        .word masked_devil
        .word $FFFF
        .word masked_devil_fireballs
        .word masked_devil_fight
        .word jaquio
        .word final_boss_head
        .word jaquio_fireball
        .word final_boss
        .word final_boss_fireballs
        .word bomberhead_sickle
        .word final_boss_tail

; --- $C1ED  Closes in and punches.
boxer:
        .word boxer_walk
        .word boxer_close
        .word boxer_wait
        .word boxer_rise
        .word boxer_punch
        .word boxer_land
; --- $C1F9  Start walking toward Ryu.
boxer_walk:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$00
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_ryu
        lda #$11
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $C21D  Keep closing in. If he has gone past Ryu, wait.
boxer_close:
        jsr toward_ryu
        bpl lC22D
        lda #$3C
        sta enemy_timer,x
        lda #$02
        sta enemy_state,x
        rts
lC22D:
        lda enemy_touch,x
        and #$30
        beq lC240
        lda #$20
        jsr ryu_away
        bcc boxer_jump
        lda #$FF
        jsr enemy_jump
lC240:
        rts
; --- $C241  The wait. Then walk toward Ryu again.
boxer_wait:
        lda enemy_timer,x
        bne lC258
        lda enemy_touch,x
        and #$30
        beq lC258
        jsr chase_ryu
        jsr face_ryu
        lda #$01
        sta enemy_state,x
lC258:
        rts
; --- $C259  Ryu is close. Jump at him.
boxer_jump:
        jsr chase_ryu
        jsr face_ryu
        lda #$FF
        jsr enemy_jump
        lda #$03
        sta enemy_state,x
        rts
; --- $C26A  In the air. On landing, jump into the punch.
boxer_rise:
        lda enemy_touch,x
        and #$30
        beq lC27B
        lda #$FF
        jsr enemy_jump
        lda #$04
        sta enemy_state,x
lC27B:
        rts
; --- $C27C  On landing, leap at Ryu and punch.
boxer_punch:
        lda enemy_touch,x
        and #$30
        beq lC2A2
        lda #$02
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_ryu
        lda #$12
        jsr set_enemy_action
        lda #$FE
        jsr enemy_jump
        lda #$05
        sta enemy_state,x
lC2A2:
        rts
; --- $C2A3  Land, and start the walk over.
boxer_land:
        lda enemy_touch,x
        and #$30
        beq lC2AF
        lda #$00
        sta enemy_state,x
lC2AF:
        rts

; --- $C2B0  Walks, then fires three shots.
machine_gunner:
        .word gunner_walk
        .word gunner_pace
        .word gunner_fire
; --- $C2B6  Walk toward Ryu.
gunner_walk:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$00
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        jsr chase_ryu
        lda #$3C
        sta enemy_timer,x
        lda #$13
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $C2DC  Keep walking until the wait is over, then aim.
gunner_pace:
        jsr face_ryu
        jsr floor_ahead
        bne lC2E7
        jsr reverse_enemy
lC2E7:
        lda enemy_timer,x
        bne lC306
        lda enemy_flags
        and #$BF
        sta enemy_flags
        lda #$14
        jsr set_enemy_action
        lda #$02
        sta $04A0,x
        lda #$0A
        sta enemy_timer,x
        lda #$02
        sta enemy_state,x
lC306:
        rts
; --- $C307  Fire three shots.
gunner_fire:
        jsr face_ryu
        jsr floor_ahead
        bne lC312
        jsr reverse_enemy
lC312:
        lda enemy_timer,x
        bne lC332
        stx $00
        jsr alloc_enemy
        bmi lC339
        jsr gun_shot
        ldx $00
        dec $04A0,x
        bmi lC333
        lda #$20
        sta sound
        lda #$0A
        sta enemy_timer,x
lC332:
        rts
lC333:
        lda #$00
        sta enemy_state,x
        rts
lC339:
        ldx $00
        rts

; --- $C33C  Walks and throws an axe.
thrower:
        .word thrower_walk
        .word thrower_pace
        .word thrower_toss
        .word thrower_hold
; --- $C344  Walk, until it is time to throw.
thrower_walk:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$00
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        lda #$16
        jsr set_enemy_action
        lda nmi_count
        lsr
        sta enemy_timer,x
        lda #$01
        sta enemy_state,x
        rts
; --- $C368  Keep walking. Turn back at a drop.
thrower_pace:
        jsr face_ryu
        jsr floor_ahead
        bne lC373
        jsr reverse_enemy
lC373:
        lda enemy_timer,x
        bne lC37D
        lda #$02
        sta enemy_state,x
lC37D:
        rts
; --- $C37E  Throw the axe.
thrower_toss:
        lda enemy_flags
        and #$BF
        sta enemy_flags
        jsr face_ryu
        jsr floor_ahead
        bne lC38F
        jsr reverse_enemy
lC38F:
        stx $00
        jsr alloc_enemy
        bmi lC3AB
        jsr throw_axe
        ldx $00
        lda #$18
        jsr set_enemy_action
        lda #$0C
        sta enemy_timer,x
        lda #$03
        sta enemy_state,x
        rts
lC3AB:
        ldx $00
        rts
; --- $C3AE  Hold the throw, then start over.
thrower_hold:
        lda enemy_timer,x
        bne lC3B8
        lda #$00
        sta enemy_state,x
lC3B8:
        rts

; --- $C3B9  Chases Ryu and swings a bat.
batter:
        .word batter_chase
        .word batter_turn
; --- $C3BD  Chase Ryu.
batter_chase:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$00
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        lda #$1A
        jsr set_enemy_action
        jsr chase_ryu
        jsr face_ryu
        lda #$01
        sta enemy_state,x
        rts
; --- $C3E1  Turn around at a wall or a drop.
batter_turn:
        jsr floor_ahead
        beq lC3EC
        jsr wall_ahead
        bne lC3EC
        rts
lC3EC:
        jsr reverse_enemy
        lda facing
        eor #$40
        sta facing
        rts

; --- $C3F6  Walks, then throws two knives.
knife_thrower:
        .word knife_arm
        .word knife_walk
        .word knife_high
        .word knife_again
        .word knife_low
        .word knife_reset
; --- $C402  Get ready to walk.
knife_arm:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$00
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        lda #$01
        sta enemy_state,x
        rts
; --- $C41B  Walk toward Ryu for a while.
knife_walk:
        jsr chase_ryu
        jsr face_ryu
        lda #$1C
        jsr set_enemy_action
        lda #$80
        sta enemy_timer,x
        lda #$02
        sta enemy_state,x
        rts
; --- $C431  Throw a knife, high.
knife_high:
        lda enemy_timer,x
        bne lC462
        stx $00
        jsr alloc_enemy
        bmi lC463
        lda enemy_flags
        and #$BF
        sta enemy_flags
        ldy $00
        sec
        lda enemy_y,y
        sbc #$0E
        jsr throw_knife
        ldx $00
        jsr face_ryu
        lda #$1D
        jsr set_enemy_action
        lda #$1B
        sta enemy_timer,x
        lda #$03
        sta enemy_state,x
lC462:
        rts
lC463:
        ldx $00
        rts
; --- $C466  Walk toward Ryu again.
knife_again:
        lda enemy_timer,x
        bne lC486
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr chase_ryu
        jsr face_ryu
        lda #$1C
        jsr set_enemy_action
        lda #$80
        sta enemy_timer,x
        lda #$04
        sta enemy_state,x
lC486:
        rts
; --- $C487  Throw a second knife, lower.
knife_low:
        lda enemy_timer,x
        bne lC4BA
        stx $00
        ldy $00
        jsr alloc_enemy
        bmi lC4BB
        lda enemy_flags
        and #$BF
        sta enemy_flags
        ldy $00
        sec
        lda enemy_y,y
        sbc #$04
        jsr throw_knife
        ldx $00
        jsr face_ryu
        lda #$1E
        jsr set_enemy_action
        lda #$1B
        sta enemy_timer,x
        lda #$05
        sta enemy_state,x
lC4BA:
        rts
lC4BB:
        ldx $00
        rts
; --- $C4BE  Then walk toward him again.
knife_reset:
        lda enemy_timer,x
        bne lC4CE
        lda enemy_flags
        ora #$40
        sta enemy_flags
        lda #$01
        sta enemy_state,x
lC4CE:
        rts

; --- $C4CF  Crouches and fires.
crouching_soldier:
        .word crouch_aim
        .word crouch_fire
        .word crouch_cycle
; --- $C4D5  Crouch and aim at Ryu.
crouch_aim:
        lda enemy_flags
        and #$BF
        sta enemy_flags
        jsr load_enemy_hp
        jsr face_ryu
        lda #$3C
        sta enemy_timer,x
        lda #$1F
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $C4F1  Fire.
crouch_fire:
        jsr face_ryu
        lda enemy_timer,x
        bne lC519
        stx $00
        jsr alloc_enemy
        bmi lC51A
        jsr crouch_shot
        lda #$21
        sta sound
        ldx $00
        lda #$20
        jsr set_enemy_action
        lda #$09
        sta enemy_timer,x
        lda #$02
        sta enemy_state,x
lC519:
        rts
lC51A:
        ldx $00
        rts
; --- $C51D  Then aim again.
crouch_cycle:
        lda enemy_timer,x
        bne lC531
        lda #$1F
        jsr set_enemy_action
        lda #$3C
        sta enemy_timer,x
        lda #$01
        sta enemy_state,x
lC531:
        rts

; --- $C532  Closes in, then spins a kick in the air.
jump_kicker:
        .word kicker_walk
        .word kicker_near
        .word kicker_pause
        .word kicker_kick
        .word kicker_land
; --- $C53C  Walk toward Ryu.
kicker_walk:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$23
        jsr set_enemy_action
        lda #$00
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        lda #$01
        sta enemy_state,x
        rts
; --- $C55A  When Ryu is close, jump in.
kicker_near:
        jsr chase_ryu
        jsr face_ryu
        lda #$38
        jsr ryu_away
        bcs lC576
        lda #$FC
        jsr enemy_jump
        lda #$24
        jsr set_enemy_action
        lda #$02
        sta enemy_state,x
lC576:
        rts
; --- $C577  Land, and pause.
kicker_pause:
        lda enemy_touch,x
        and #$30
        beq lC58D
        lda #$23
        jsr set_enemy_action
        lda #$1E
        sta enemy_timer,x
        lda #$03
        sta enemy_state,x
lC58D:
        rts
; --- $C58E  Jump, and spin the kick. Four pictures, one frame each, until he lands.
kicker_kick:
        lda enemy_timer,x
        bne lC5AD
        jsr chase_ryu
        jsr face_ryu
        lda #$25
        jsr set_enemy_action
        lda #$80
        sta enemy_timer,x
        lda #$FB
        jsr enemy_jump
        lda #$04
        sta enemy_state,x
lC5AD:
        rts
; --- $C5AE  Land, and start over.
kicker_land:
        lda enemy_touch,x
        and #$30
        beq lC5BA
        lda #$00
        sta enemy_state,x
lC5BA:
        rts

; --- $C5BB  Runs and hops.
running_soldier:
        .word runner_go
        .word runner_hop
        .word runner_land
; --- $C5C1  Run toward Ryu.
runner_go:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$02
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_ryu
        lda #$26
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $C5E5  Hop over a gap or a wall.
runner_hop:
        jsr floor_ahead
        beq lC5EF
        jsr wall_ahead
        beq lC5FE
lC5EF:
        lda #$FC
        jsr enemy_jump
        lda #$27
        jsr set_enemy_action
        lda #$02
        sta enemy_state,x
lC5FE:
        rts
; --- $C5FF  Land, and run again.
runner_land:
        lda enemy_touch,x
        and #$30
        beq lC610
        lda #$26
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
lC610:
        rts

; --- $C611  Flies in a wave.
bat:
        .word bat_swoop
        .word bat_bob
; --- $C615  Fly in, around Ryu's height.
bat_swoop:
        lda enemy_flags
        ora #$C0
        sta enemy_flags
        jsr load_enemy_hp
        lda #$01
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_ryu
        lda #$00
        sta enemy_y_spd,x
        lda #$80
        sta enemy_y_frac,x
        lda height
        sta $04A0,x
        sec
        sbc #$10
        sta enemy_y,x
        lda #$28
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $C64E  Rise and fall around that height.
bat_bob:
        sec
        lda $04A0,x
        sbc enemy_y,x
        bcc lC669
        clc
        lda enemy_y_frac,x
        adc #$40
        sta enemy_y_frac,x
        lda enemy_y_spd,x
        adc #$00
        sta enemy_y_spd,x
        rts
lC669:
        sec
        lda enemy_y_frac,x
        sbc #$40
        sta enemy_y_frac,x
        lda enemy_y_spd,x
        sbc #$00
        sta enemy_y_spd,x
        rts

; --- $C67B  Runs and leaps at Ryu.
attacking_dog:
        .word hound_run
        .word hound_leap
; --- $C67F  Run at Ryu.
hound_run:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$02
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_ryu
        lda #$2A
        jsr set_enemy_action
        lda $57
        beq lC6A7
        lda #$01
        ora facing
        sta facing
lC6A7:
        jsr chase_ryu
        jsr face_ryu
        lda #$01
        sta enemy_state,x
        rts
; --- $C6B3  Turn at a wall, and leap along the ground.
hound_leap:
        jsr wall_ahead
        beq lC6C1
        jsr reverse_enemy
        lda facing
        eor #$40
        sta facing
lC6C1:
        lda enemy_touch,x
        and #$30
        beq lC6CD
        lda #$FE
        jsr enemy_jump
lC6CD:
        rts

; --- $C6CE  Sits until Ryu is close, then runs and leaps.
waiting_dog:
        .word dog_sit
        .word dog_wake
        .word dog_leap
; --- $C6D4  Sit, facing Ryu.
dog_sit:
        lda enemy_flags
        and #$BF
        sta enemy_flags
        jsr load_enemy_hp
        lda #$29
        jsr set_enemy_action
        lda $57
        beq lC6EC
        lda #$01
        ora facing
        sta facing
lC6EC:
        jsr face_ryu
        lda #$01
        sta enemy_state,x
        rts
; --- $C6F5  When Ryu is close, run.
dog_wake:
        lda #$40
        jsr ryu_away
        bcs lC719
        lda enemy_flags
        ora #$40
        sta enemy_flags
        lda #$02
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        lda #$2A
        jsr set_enemy_action
        lda #$02
        sta enemy_state,x
lC719:
        rts
; --- $C71A  Turn at a wall, and leap.
dog_leap:
        jsr wall_ahead
        beq lC728
        jsr reverse_enemy
        lda facing
        eor #$40
        sta facing
lC728:
        lda enemy_touch,x
        and #$30
        beq lC734
        lda #$FD
        jsr enemy_jump
lC734:
        rts

; --- $C735  Flies toward Ryu.
bird:
        .word bird_rise
        .word bird_home
; --- $C739  Fly toward Ryu.
bird_rise:
        lda enemy_flags
        ora #$C0
        sta enemy_flags
        jsr load_enemy_hp
        lda #$00
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_ryu
        lda #$2B
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $C75D  Match his height, then steer sideways.
bird_home:
        sec
        lda height
        sbc enemy_y,x
        bcc lC76A
        inc enemy_y,x
        bne home_x
lC76A:
        dec enemy_y,x
; --- $C76D  Steer sideways toward Ryu.
home_x:
        sec
        lda enemy_x,x
        sbc ryu_x
        bcc lC78D
        sec
        lda enemy_x_frac,x
        sbc #$10
        sta enemy_x_frac,x
        lda enemy_x_spd,x
        sbc #$00
        sta enemy_x_spd,x
        lda facing
        ora #$40
        sta facing
        rts
lC78D:
        clc
        lda enemy_x_frac,x
        adc #$10
        sta enemy_x_frac,x
        lda enemy_x_spd,x
        adc #$00
        sta enemy_x_spd,x
        lda facing
        and #$BF
        sta facing
        rts

; --- $C7A5  Hovers, and throws a shuriken when Ryu is near.
jetpack_ninja:
        .word jet_hover
        .word jet_aim
        .word jet_thrown
; --- $C7AB  Hover, facing Ryu.
jet_hover:
        lda enemy_flags
        ora #$C0
        sta enemy_flags
        jsr load_enemy_hp
        sec
        lda height
        sbc #$20
        sta enemy_y,x
        lda #$00
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        lda #$2E
        jsr set_enemy_action
        jsr chase_ryu
        jsr face_ryu
        lda #$01
        sta enemy_state,x
        rts
; --- $C7D7  When Ryu is near, throw a shuriken.
jet_aim:
        lda #$30
        jsr enemy_thrust
        sec
        lda ryu_x
        sbc enemy_x,x
        bpl lC7E9
        eor #$FF
        clc
        adc #$01
lC7E9:
        cmp #$60
        bcs lC80D
        stx $00
        jsr alloc_enemy
        bmi lC80B
        ldy $00
        jsr ninja_star
        ldx $00
        lda #$2F
        jsr set_enemy_action
        lda #$20
        sta enemy_timer,x
        lda #$02
        sta enemy_state,x
        rts
lC80B:
        ldx $00
lC80D:
        rts
; --- $C80E  Hold the throw, then hover again.
jet_thrown:
        lda enemy_timer,x
        bne lC81D
        lda #$2E
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
lC81D:
        rts

; --- $C81E  Runs, and jumps when Ryu is close.
running_ninja:
        .word ninja_stand
        .word ninja_run
        .word ninja_jump
        .word ninja_land
        .word ninja_resume
; --- $C828  Stand until he is on the ground.
ninja_stand:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$00
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr face_ryu
        lda #$31
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $C849  Then run toward Ryu.
ninja_run:
        lda enemy_touch,x
        and #$30
        beq lC86A
        lda #$01
        sta enemy_x_spd,x
        lda #$C0
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_ryu
        lda #$33
        jsr set_enemy_action
        lda #$02
        sta enemy_state,x
lC86A:
        rts
; --- $C86B  Jump at a wall, a gap, or when Ryu is close.
ninja_jump:
        jsr wall_ahead
        bne lC87C
        jsr floor_ahead
        beq lC87C
        lda #$80
        jsr ryu_away
        bcs lC88B
lC87C:
        lda #$31
        jsr set_enemy_action
        lda #$03
        sta enemy_state,x
        lda #$FB
        jsr enemy_jump
lC88B:
        rts
; --- $C88C  Land, and pause.
ninja_land:
        lda enemy_touch,x
        and #$30
        beq lC8A2
        lda #$1E
        sta enemy_timer,x
        lda #$33
        jsr set_enemy_action
        lda #$04
        sta enemy_state,x
lC8A2:
        rts
; --- $C8A3  Then run again.
ninja_resume:
        lda enemy_timer,x
        bne lC8B3
        jsr chase_ryu
        jsr face_ryu
        lda #$02
        sta enemy_state,x
lC8B3:
        rts

; --- $C8B4  Paces, then throws a ring.
stone_man:
        .word stone_start
        .word stone_pace
        .word stone_throw
        .word stone_follow
        .word stone_rest
; --- $C8BE  Pace, walking back from Ryu at first.
stone_start:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        lda #$01
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr load_enemy_hp
        lda #$35
        jsr set_enemy_action
        jsr face_ryu
        jsr chase_ryu
        jsr reverse_enemy
        lda #$0A
        sta enemy_timer,x
        lda #$01
        sta enemy_state,x
        rts
; --- $C8EA  Walk between the two marks, then wind up.
stone_pace:
        lda enemy_timer,x
        beq lC925
        jsr chase_ryu
        jsr face_ryu
        lda enemy_x,x
        bit facing
        bvc lC904
        cmp #$D0
        beq lC919
        bmi lC90A
        bpl lC90D
lC904:
        cmp #$30
        beq lC919
        bmi lC90D
lC90A:
        jsr reverse_enemy
lC90D:
        lda #$35
        jsr set_enemy_action
        lda enemy_flags
        ora #$40
        sta enemy_flags
        rts
lC919:
        lda #$34
        jsr set_enemy_action
        lda enemy_flags
        and #$BF
        sta enemy_flags
        rts
lC925:
        jsr chase_ryu
        jsr face_ryu
        lda #$36
        jsr set_enemy_action
        lda #$14
        sta enemy_timer,x
        lda #$02
        sta enemy_state,x
        rts
; --- $C93B  Throw the ring.
stone_throw:
        lda enemy_timer,x
        bne lC95F
        stx $00
        jsr alloc_enemy
        bmi lC960
        lda #$1A
        sta sound
        jsr throw_ring
        txa
        ldx $00
        sta $04A0,x
        lda #$0A
        sta enemy_timer,x
        lda #$03
        sta enemy_state,x
lC95F:
        rts
lC960:
        ldx $00
        rts
; --- $C963  Walk between the marks again.
stone_follow:
        lda enemy_timer,x
        beq lC99E
        jsr chase_ryu
        jsr face_ryu
        lda enemy_x,x
        bit facing
        bvc lC97D
        cmp #$D0
        beq lC992
        bmi lC983
        bpl lC986
lC97D:
        cmp #$30
        beq lC983
        bmi lC986
lC983:
        jsr reverse_enemy
lC986:
        lda #$37
        jsr set_enemy_action
        lda enemy_flags
        ora #$40
        sta enemy_flags
        rts
lC992:
        lda #$38
        jsr set_enemy_action
        lda enemy_flags
        and #$BF
        sta enemy_flags
        rts
lC99E:
        lda #$28
        sta enemy_timer,x
        lda #$04
        sta enemy_state,x
        rts
; --- $C9A9  Wait, then pace again.
stone_rest:
        lda enemy_timer,x
        bne lC9B3
        lda #$01
        sta enemy_state,x
lC9B3:
        rts

; --- $C9B4  Hops toward Ryu.
crouched_ghoul:
        .word ghoul_hop
        .word ghoul_bounce
        .word ghoul_land
; --- $C9BA  Hop toward Ryu.
ghoul_hop:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr load_enemy_hp
        lda #$02
        sta enemy_x_spd,x
        lda #$40
        sta enemy_x_frac,x
        lda $57
        cmp #$06
        bne lC9D9
        lda #$01
        ora facing
        sta facing
lC9D9:
        jsr chase_ryu
        jsr face_ryu
        lda #$3A
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $C9EA  A small hop while he is far, a long one when he is close.
ghoul_bounce:
        lda enemy_touch,x
        and #$30
        beq lCA02
        lda #$20
        jsr ryu_away
        bcc lCA03
        lda #$FF
        jsr enemy_jump
        lda #$3A
        jsr set_enemy_action
lCA02:
        rts
lCA03:
        lda #$FC
        jsr enemy_jump
        lda #$3B
        jsr set_enemy_action
        lda #$02
        sta enemy_state,x
        rts
; --- $CA13  Land, and hop again.
ghoul_land:
        lda enemy_touch,x
        and #$30
        beq lCA25
        jsr chase_ryu
        jsr face_ryu
        lda #$01
        sta enemy_state,x
lCA25:
        rts

; --- $CA26  Waits, then hops toward Ryu.
waiting_ghoul:
        .word lurker_wait
        .word lurker_wake
        .word lurker_bounce
        .word lurker_land
; --- $CA2E  Wait, facing Ryu.
lurker_wait:
        lda enemy_flags
        and #$BF
        sta enemy_flags
        lda #$01
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        jsr load_enemy_hp
        jsr chase_ryu
        jsr face_ryu
        lda #$3A
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $CA52  When he is close, start hopping.
lurker_wake:
        lda #$28
        jsr ryu_away
        bcs lCA64
        lda enemy_flags
        ora #$40
        sta enemy_flags
        lda #$02
        sta enemy_state,x
lCA64:
        rts
; --- $CA65  A small hop while he is far, a long one when he is close.
lurker_bounce:
        lda enemy_touch,x
        and #$30
        beq lCA7D
        lda #$20
        jsr ryu_away
        bcc lCA7E
        lda #$FF
        jsr enemy_jump
        lda #$3A
        jsr set_enemy_action
lCA7D:
        rts
lCA7E:
        lda #$FC
        jsr enemy_jump
        lda #$3B
        jsr set_enemy_action
        lda #$03
        sta enemy_state,x
        rts
; --- $CA8E  Land, and hop again.
lurker_land:
        lda enemy_touch,x
        and #$30
        beq lCAA0
        jsr chase_ryu
        jsr face_ryu
        lda #$02
        sta enemy_state,x
lCAA0:
        rts

; --- $CAA1  The machine gunner's shot. Flies straight.
machine_gun_bullet:
        .word gun_shot
        .word leave_actor
; --- $CAA5  The machine gunner's shot. Send it at Ryu.
gun_shot:
        lda #$11
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        ldy $00
        lda slot_flags,x
        ora #$C2
        sta slot_flags,x
        lda enemy_x,y
        sta enemy_x,x
        sec
        lda enemy_y,y
        sbc #$0F
        sta enemy_y,x
        lda #$02
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_spawn
        lda #$15
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts

; --- $CAE5  The thrower's axe. It arcs.
axe:
        .word throw_axe
        .word axe_fall
; --- $CAE9  The thrower's axe. Lob it.
throw_axe:
        lda #$12
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        ldy $00
        lda #$C2
        sta slot_flags,x
        lda enemy_x,y
        sta enemy_x,x
        sec
        lda enemy_y,y
        sbc #$18
        sta enemy_y,x
        lda nmi_count
        sta enemy_x_frac,x
        and #$01
        sta enemy_x_spd,x
        jsr chase_ryu
        jsr face_spawn
        lda nmi_count
        sta enemy_y_frac,x
        lda #$FC
        sta enemy_y_spd,x
        lda #$19
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $CB30  The axe falls.
axe_fall:
        jmp enemy_gravity

; --- $CB33  A thrown knife. Flies straight.
knife:
        .word throw_knife
        .word leave_actor
; --- $CB37  A thrown knife. Send it at Ryu.
throw_knife:
        sta enemy_y,x
        lda enemy_x,y
        sta enemy_x,x
        lda #$13
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda slot_flags,x
        ora #$C2
        sta slot_flags,x
        lda #$02
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_spawn
        lda #$5E
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts

; --- $CB6F  The crouching soldier's shot.
crouching_soldier_bullet:
        .word crouch_shot
        .word leave_actor
; --- $CB73  The crouching soldier's shot. Send it at Ryu.
crouch_shot:
        lda #$14
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda $57
        cmp #$04
        bne lCB8A
        lda #$01
        sta slot_facing,x
lCB8A:
        ldy $00
        lda slot_flags,x
        ora #$C2
        sta slot_flags,x
        lda enemy_x,y
        sta enemy_x,x
        sec
        lda enemy_y,y
        sbc #$0D
        sta enemy_y,x
        lda #$02
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_spawn
        lda #$21
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts

; --- $CBBE  The jetpack ninja's shuriken.
shuriken:
        .word ninja_star
        .word leave_actor
; --- $CBC2  The jetpack ninja's shuriken. Send it at Ryu.
ninja_star:
        lda #$15
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda slot_flags,x
        ora #$C2
        sta slot_flags,x
        ldy $00
        lda enemy_x,y
        sta enemy_x,x
        lda enemy_y,y
        sta enemy_y,x
        lda #$30
        jsr set_enemy_action
        lda #$01
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        lda #$01
        sta enemy_y_spd,x
        lda #$00
        sta enemy_y_frac,x
        jsr chase_ryu
        jsr face_spawn
        lda #$01
        sta enemy_state,x
        rts

; --- $CC09  The stone man's ring. It comes back to him.
stone_man_ring:
        .word ring_back
; --- $CC0B  The stone man's ring. Send it out.
throw_ring:
        lda #$16
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda #$C2
        sta slot_flags,x
        lda $00
        sta $04A0,x
        tay
        lda enemy_x,y
        sta enemy_x,x
        sec
        lda enemy_y,y
        sbc #$0A
        sta enemy_y,x
        lda #$06
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        jsr chase_ryu
        lda #$39
        jsr set_enemy_action
        lda #$0A
        sta enemy_timer,x
        lda #$00
        sta enemy_state,x
        rts
; --- $CC4E  The ring comes back. It vanishes when it reaches him.
ring_back:
        lda enemy_timer,x
        bne lCC82
        ldy $04A0,x
        sec
        lda enemy_x,y
        sbc enemy_x,x
        sta $00
        bpl lCC66
        eor #$FF
        clc
        adc #$01
lCC66:
        cmp #$10
        bcs lCC6D
        jmp free_enemy
lCC6D:
        bit $00
        bpl lCC83
        sec
        lda enemy_x_frac,x
        sbc #$80
        sta enemy_x_frac,x
        lda enemy_x_spd,x
        sbc #$00
        sta enemy_x_spd,x
lCC82:
        rts
lCC83:
        clc
        lda enemy_x_frac,x
        adc #$80
        sta enemy_x_frac,x
        lda enemy_x_spd,x
        adc #$00
        sta enemy_x_spd,x
        rts

; --- $CC95  Walks in and swings his sword.
barbarian:
        .word barbarian_setup
        .word barbarian_walk
        .word barbarian_stride
        .word barbarian_stop
        .word barbarian_hold
        .word barbarian_turn
        .word barbarian_face
        .word barbarian_pause
; --- $CCA5  Set him up.
barbarian_setup:
        lda #$80
        sta $77
        lda enemy_flags
        ora #$01
        sta enemy_flags
        jsr load_enemy_hp
        jsr load_enemy_hp
        lda #$00
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        lda #$01
        sta enemy_state,x
        rts
; --- $CCC5  Walk toward Ryu.
barbarian_walk:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        lda #$3D
        jsr set_enemy_action
        lda #$40
        sta enemy_timer,x
        jsr chase_ryu
        jsr face_ryu
        lda #$02
        sta enemy_state,x
        rts
; --- $CCE1  Keep walking until the timer runs out.
barbarian_stride:
        lda enemy_timer,x
        bne lCCEB
        lda #$03
        sta enemy_state,x
lCCEB:
        rts
; --- $CCEC  Stop walking and swing the sword.
barbarian_stop:
        lda enemy_flags
        and #$BF
        sta enemy_flags
        lda #$3E
        jsr set_enemy_action
        lda #$6C
        sta enemy_timer,x
        lda #$04
        sta enemy_state,x
        rts
; --- $CD02  Hold that pose.
barbarian_hold:
        lda enemy_timer,x
        bne lCD0C
        lda #$05
        sta enemy_state,x
lCD0C:
        rts
; --- $CD0D  Turn around if a wall is ahead.
barbarian_turn:
        jsr wall_ahead
        beq lCD18
        jsr chase_ryu
        jsr face_ryu
lCD18:
        lda #$06
        sta enemy_state,x
        rts
; --- $CD1E  If he faces Ryu, walk again. Otherwise wait.
barbarian_face:
        jsr facing_ryu
        bpl lCD33
        lda #$3C
        sta enemy_timer,x
        lda #$07
        sta enemy_state,x
        rts
; --- $CD2E  Wait, then walk again.
barbarian_pause:
        lda enemy_timer,x
        bne lCD38
lCD33:
        lda #$01
        sta enemy_state,x
lCD38:
        rts

; --- $CD39  Swings a spinning sickle on a chain.
bomberhead:
        .word bomber_setup
        .word bomber_close
        .word bomber_swing
        .word bomber_chase
; --- $CD41  Take his place and start the sickle.
bomber_setup:
        lda #$80
        sta $77
        lda enemy_flags
        ora #$41
        sta enemy_flags
        lda #$00
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        lda #$40
        sta enemy_x,x
        lda #$D0
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        jsr load_enemy_hp
        lda #$3F
        jsr set_enemy_action
        lda #$1C
        sta sound
        jsr chase_ryu
        jsr face_ryu
        stx $00
        jsr spawn_sickle
        ldx $00
        lda #$01
        sta enemy_state,x
        rts
; --- $CD87  When Ryu is close, stop and change his pose.
bomber_close:
        lda #$20
        jsr ryu_away
        bcs lCDA3
        lda enemy_flags
        and #$BF
        sta enemy_flags
        lda #$40
        jsr set_enemy_action
        lda #$90
        sta enemy_timer,x
        lda #$02
        sta enemy_state,x
lCDA3:
        rts
; --- $CDA4  Hold that pose, then walk again.
bomber_swing:
        lda enemy_timer,x
        bne lCDC4
        lda enemy_flags
        ora #$40
        sta enemy_flags
        lda #$3F
        jsr set_enemy_action
        jsr chase_ryu
        jsr face_ryu
        lda #$78
        sta enemy_timer,x
        lda #$03
        sta enemy_state,x
lCDC4:
        rts
; --- $CDC5  Walk until the timer runs out.
bomber_chase:
        jsr chase_ryu
        jsr face_ryu
        lda enemy_timer,x
        bne lCDD5
        lda #$01
        sta enemy_state,x
lCDD5:
        rts
; --- $CDD6  Give him the sickle.
spawn_sickle:
        jsr alloc_enemy
        bmi lCDFB
        lda #$2A
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda #$82
        sta slot_flags,x
        lda $00
        sta $04A0,x
        lda #$6A
        jsr set_enemy_action
        lda #$00
        sta enemy_state,x
lCDFB:
        rts

; --- $CDFC  The sickle, swinging on its chain.
bomberhead_sickle:
        .word sickle_place
; --- $CDFE  Follow him. His pose picks how far out it sits.
sickle_place:
        ldy $04A0,x
        lda enemy_pose,y
        cmp #$4C
        beq sickle_out
        cmp #$4D
        beq sickle_low
        lda slot_facing,y
        and #$40
        bne lCE1E
        sec
        lda enemy_x,y
        sbc #$04
        sta enemy_x,x
        bne lCE44
lCE1E:
        clc
        lda enemy_x,y
        adc #$04
        sta enemy_x,x
        bne lCE44
; --- $CE29  Sixteen pixels out.
sickle_out:
        lda slot_facing,y
        and #$40
        bne lCE3B
        sec
        lda enemy_x,y
        sbc #$10
        sta enemy_x,x
        bne lCE44
lCE3B:
        clc
        lda enemy_x,y
        adc #$10
        sta enemy_x,x
lCE44:
        sec
        lda enemy_y,y
        sbc #$25
        sta enemy_y,x
        rts
; --- $CE4E  Further out, and lower.
sickle_low:
        lda slot_facing,y
        and #$40
        bne lCE60
        clc
        lda enemy_x,y
        adc #$16
        sta enemy_x,x
        bne lCE69
lCE60:
        sec
        lda enemy_x,y
        sbc #$16
        sta enemy_x,x
lCE69:
        sec
        lda enemy_y,y
        sbc #$18
        sta enemy_y,x
        rts

; --- $CE73  Hops in an arc from side to side, and sometimes fires three shots.
basaquer:
        .word basaquer_enter
        .word basaquer_jump
        .word basaquer_land
        .word basaquer_turn
        .word basaquer_fire
        .word lCF14
; --- $CE7F  Drop in from the right.
basaquer_enter:
        lda #$80
        sta $77
        lda enemy_flags
        ora #$01
        sta enemy_flags
        jsr load_enemy_hp
        lda #$D0
        sta enemy_x,x
        lda #$D0
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        lda #$FD
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
; --- $CEA8  Hop. His sideways speed stays, so the jump arcs.
basaquer_jump:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        jsr face_ryu
        lda #$44
        jsr set_enemy_action
        lda #$FA
        jsr enemy_jump
        lda #$02
        sta enemy_state,x
        rts
; --- $CEC1  Land, and hold still.
basaquer_land:
        lda enemy_touch,x
        and #$30
        beq lCEE2
        lda #$41
        sta sound
        lda enemy_flags
        and #$BF
        sta enemy_flags
        lda #$43
        jsr set_enemy_action
        lda #$14
        sta enemy_timer,x
        lda #$03
        sta enemy_state,x
lCEE2:
        rts
; --- $CEE3  Reverse. When he is the only one left, fire on half the frames.
basaquer_turn:
        lda enemy_timer,x
        bne lCF00
        jsr reverse_enemy
        lda facing
        eor #$40
        sta facing
        lda enemy_count
        cmp #$01
        bne lCEFB
        bit nmi_count
        bmi basaquer_fire
lCEFB:
        lda #$01
        sta enemy_state,x
lCF00:
        rts
; --- $CF01  Fire three shots.
basaquer_fire:
        stx $00
        jsr shot_high
        jsr shot_mid
        jsr shot_low
        ldx $00
        lda #$01
        sta enemy_state,x
        rts
lCF14:
        lda enemy_count
        cmp #$01
        bne lCF1F
        lda #$01
        sta enemy_state,x
lCF1F:
        rts
; --- $CF20  A shot above him.
shot_high:
        jsr spawn_shot
        ldy $00
        sec
        lda enemy_y,y
        sbc #$20
        sta enemy_y,x
        lda #$01
        sta enemy_timer,x
        lda #$00
        sta enemy_state,x
        rts
; --- $CF39  A shot a little above him.
shot_mid:
        jsr spawn_shot
        ldy $00
        sec
        lda enemy_y,y
        sbc #$10
        sta enemy_y,x
        lda #$0A
        sta enemy_timer,x
        lda #$00
        sta enemy_state,x
        rts
; --- $CF52  A shot at his height.
shot_low:
        jsr spawn_shot
        ldy $00
        sec
        lda enemy_y,y
        sta enemy_y,x
        lda #$14
        sta enemy_timer,x
        lda #$00
        sta enemy_state,x
        rts
; --- $CF69  Make one of his shots.
spawn_shot:
        jsr alloc_enemy
        bmi lCFA1
        ldy $00
        lda enemy_x,y
        sta enemy_x,x
        lda #$1A
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda #$82
        sta slot_flags,x
        lda #$02
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_spawn
        lda #$45
        jsr set_enemy_action
        lda #$00
        sta enemy_state,x
lCFA1:
        rts

; --- $CFA2  One of Basaquer's shots.
basaquer_shot:
        .word shot_release
; --- $CFA4  Wait, then let it fly.
shot_release:
        lda enemy_timer,x
        bne lCFAF
        lda enemy_flags
        ora #$40
        sta enemy_flags
lCFAF:
        rts

; --- $CFB0  Two of the same creature. They jump and breathe fire.
kelbeross:
        .word kelbeross_enter
        .word kelbeross_jump
        .word kelbeross_breathe
; --- $CFB6  Both of them take their places, facing opposite ways.
kelbeross_enter:
        jsr kelbeross_ready
        lda #$80
        sta $77
        lda #$01
        sta enemy_flags
        lda #$3E
        sta enemy_x,x
        lda #$A0
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        lda #$01
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        stx $00
        jsr alloc_enemy
        bmi lD012
        lda #$1B
        sta enemy_type,x
        jsr kelbeross_ready
        lda #$00
        sta slot_flags,x
        lda #$40
        sta slot_facing,x
        lda #$B0
        sta enemy_x,x
        lda #$A0
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        lda #$FF
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
lD012:
        ldx $00
        rts
; --- $D015  A head waits.
kelbeross_ready:
        jsr load_enemy_hp
        lda #$46
        jsr set_enemy_action
        lda #$78
        sta enemy_timer,x
        lda #$78
        sta $04A0,x
        lda #$01
        sta enemy_state,x
        rts
; --- $D02D  Jump.
kelbeross_jump:
        lda enemy_timer,x
        bne lD051
        lda enemy_flags
        ora #$44
        sta enemy_flags
        lda #$47
        jsr set_enemy_action
        lda #$FC
        sta enemy_y_spd,x
        lda #$00
        sta enemy_y_frac,x
        lda nmi_count
        sta enemy_x_frac,x
        lda #$02
        sta enemy_state,x
lD051:
        rts
; --- $D052  Breathe fire, and turn at a wall.
kelbeross_breathe:
        dec $04A0,x
        bne lD06A
        stx $00
        jsr alloc_enemy
        bmi lD063
        ldy $00
        jsr kelbeross_fire
lD063:
        ldx $00
        lda #$28
        sta $04A0,x
lD06A:
        jsr wall_ahead
        beq lD07E
        jsr reverse_enemy
        lda facing
        eor #$40
        sta facing
        lda #$FC
        jsr enemy_jump
        rts
lD07E:
        lda enemy_touch,x
        and #$30
        beq lD09F
        lda #$41
        sta sound
        lda enemy_flags
        and #$BF
        sta enemy_flags
        lda #$46
        jsr set_enemy_action
        lda #$14
        sta enemy_timer,x
        lda #$01
        sta enemy_state,x
lD09F:
        rts
; --- $D0A0  Breathe one fireball.
kelbeross_fire:
        lda #$1C
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda slot_flags,x
        ora #$C2
        sta slot_flags,x
        ldy $00
        lda enemy_x,y
        sta enemy_x,x
        sec
        lda enemy_y,y
        sbc #$20
        sta enemy_y,x
        lda #$01
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        lda #$49
        jsr set_enemy_action
        ldy $00
        lda slot_facing,y
        and #$40
        sta slot_facing,x
        beq lD0E5
        lda #$FE
        sta enemy_x_spd,x
lD0E5:
        lda #$00
        sta enemy_state,x
        rts

; --- $D0EB  Kelbeross's fireball.
kelbeross_fireball:
        .word leave_actor

; --- $D0ED  Walks, then calls down lightning.
bloody_malth:
        .word malth_enter
        .word malth_stop
        .word malth_call
        .word malth_pose
        .word malth_again
; --- $D0F7  Take his place and walk.
malth_enter:
        lda #$80
        sta $77
        jsr load_enemy_hp
        lda #$00
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        lda #$40
        sta enemy_x,x
        lda #$D0
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
; --- $D11A  Walk toward Ryu.
malth_walk:
        jsr face_ryu
        lda #$41
        sta enemy_flags
        lda #$3C
        sta enemy_timer,x
        lda #$4C
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts
; --- $D131  Stop and turn.
malth_stop:
        lda enemy_timer,x
        bne lD14C
        lda enemy_flags
        and #$BF
        sta enemy_flags
        lda #$4B
        jsr set_enemy_action
        jsr reverse_enemy
        jsr face_ryu
        lda #$02
        sta enemy_state,x
lD14C:
        rts
; --- $D14D  Call down lightning.
malth_call:
        jsr call_lightning
        lda #$32
        sta enemy_timer,x
        lda #$03
        sta enemy_state,x
        rts
; --- $D15B  Hold the next pose.
malth_pose:
        lda enemy_timer,x
        bne lD16F
        lda #$4D
        jsr set_enemy_action
        lda #$14
        sta enemy_timer,x
        lda #$04
        sta enemy_state,x
lD16F:
        rts
; --- $D170  Walk again.
malth_again:
        lda enemy_timer,x
        bne lD178
        jmp malth_walk
lD178:
        rts
; --- $D179  The lightning, beside him.
call_lightning:
        stx $00
        jsr alloc_enemy
        bmi lD1C0
        lda #$1F
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda #$C2
        sta slot_flags,x
        ldy $00
        lda #$40
        sta slot_facing,x
        lda #$F8
        bit facing
        bvc lD1A0
        lda #$10
lD1A0:
        clc
        adc enemy_x,y
        sta enemy_x,x
        lda #$A6
        sta enemy_y,x
        lda #$4E
        jsr set_enemy_action
        lda #$1E
        sta enemy_timer,x
        lda #$00
        sta enemy_state,x
        lda #$1E
        sta sound
lD1C0:
        ldx $00
        rts

; --- $D1C3  The lightning. It falls toward Ryu.
bloody_malth_lightning:
        .word bolt_wait
        .word bolt_aim
        .word bolt_fall
; --- $D1C9  Wait, then change.
bolt_wait:
        lda enemy_timer,x
        bne lD1DD
        lda #$4F
        jsr set_enemy_action
        lda #$1E
        sta enemy_timer,x
        lda #$01
        sta enemy_state,x
lD1DD:
        rts
; --- $D1DE  Aim at Ryu.
bolt_aim:
        lda enemy_timer,x
        bne lD1FD
        lda #$03
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        jsr chase_ryu
        jsr face_ryu
        lda #$50
        jsr set_enemy_action
        lda #$02
        sta enemy_state,x
lD1FD:
        rts
; --- $D1FE  Fall toward him.
bolt_fall:
        lda #$80
        jsr enemy_thrust
        sec
        lda height
        sbc enemy_y,x
        bcc lD215
        clc
        lda enemy_y,x
        adc #$04
        sta enemy_y,x
        rts
lD215:
        sec
        lda enemy_y,x
        sbc #$04
        sta enemy_y,x
        rts

; --- $D21F  A large fighter, a sword out to either side. Walks in from the right.
masked_devil:
        .word devil_walk
        .word devil_call
; --- $D223  Walk toward Ryu.
devil_walk:
        lda enemy_flags
        ora #$40
        sta enemy_flags
        lda #$00
        sta enemy_x_spd,x
        lda #$40
        sta enemy_x_frac,x
        jsr load_enemy_hp
        lda #$D0
        sta enemy_x,x
        lda #$D0
        sta enemy_y,x
        lda #$41
        jsr set_enemy_action
        jsr chase_ryu
        jsr face_ryu
        lda #$78
        sta enemy_timer,x
        lda #$01
        sta enemy_state,x
        rts
; --- $D256  Keep walking, and call a fireball.
devil_call:
        jsr chase_ryu
        jsr face_ryu
        lda enemy_timer,x
        bne lD26F
        stx $00
        ldy $00
        jsr devil_spawn
        ldx $00
        lda #$3C
        sta enemy_timer,x
lD26F:
        rts
; --- $D270  A fireball, in the middle of the room. It steers toward him.
devil_spawn:
        jsr alloc_enemy
        bmi lD2AD
        lda #$1A
        sta sound
        lda #$88
        sta enemy_x,x
        lda #$78
        sta enemy_y,x
        lda #$23
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda #$C2
        sta slot_flags,x
        lda #$00
        sta enemy_x_frac,x
        sta enemy_x_spd,x
        sta enemy_y_frac,x
        sta enemy_y_spd,x
        lda #$42
        jsr set_enemy_action
        lda $00
        sta $04A0,x
lD2AD:
        rts

; --- $D2AE  Fireballs. They appear in the middle and steer toward the walking one.
masked_devil_fireballs:
        .word ball_steer_x
        .word ball_steer_y
; --- $D2B2  Steer sideways toward the one who fired it.
ball_steer_x:
        ldy $04A0,x
        sec
        lda enemy_x,x
        sbc enemy_x,y
        bmi lD2D5
        sec
        lda enemy_x_frac,x
        sbc #$80
        sta enemy_x_frac,x
        lda enemy_x_spd,x
        sbc #$00
        sta enemy_x_spd,x
        lda #$01
        sta enemy_state,x
        rts
lD2D5:
        clc
        lda enemy_x_frac,x
        adc #$80
        sta enemy_x_frac,x
        lda enemy_x_spd,x
        adc #$00
        sta enemy_x_spd,x
        lda #$01
        sta enemy_state,x
        rts
; --- $D2EC  Steer up or down toward a point above him.
ball_steer_y:
        ldy $04A0,x
        sec
        lda enemy_y,y
        sbc #$30
        sec
        sbc enemy_y,x
        bpl lD312
        sec
        lda enemy_y_frac,x
        sbc #$80
        sta enemy_y_frac,x
        lda enemy_y_spd,x
        sbc #$00
        sta enemy_y_spd,x
        lda #$00
        sta enemy_state,x
        rts
lD312:
        clc
        lda enemy_y_frac,x
        adc #$80
        sta enemy_y_frac,x
        lda enemy_y_spd,x
        adc #$00
        sta enemy_y_spd,x
        lda #$00
        sta enemy_state,x
        rts

; --- $D329  The orb in the middle of the room. It never moves.
masked_devil_fight:
        .word devil_still
        .word leave_actor
; --- $D32D  Place the orb in the middle. Then leave it there.
devil_still:
        lda #$80
        ora $77
        sta $77
        jsr load_enemy_hp
        lda #$81
        sta enemy_flags
        lda #$87
        sta enemy_x,x
        lda #$78
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        lda #$69
        jsr set_enemy_action
        lda #$01
        sta enemy_state,x
        rts

; --- $D357  Floats from side to side and throws fireballs.
jaquio:
        .word jaquio_enter
        .word jaquio_pace
; --- $D35B  Float above the ground.
jaquio_enter:
        lda #$80
        ora $77
        sta $77
        lda #$C1
        sta enemy_flags
        jsr load_enemy_hp
        lda #$C0
        sta enemy_x,x
        lda #$60
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        lda #$01
        sta enemy_x_spd,x
        lda #$80
        sta enemy_x_frac,x
        lda #$56
        jsr set_enemy_action
        lda #$80
        sta enemy_timer,x
        lda #$01
        sta enemy_state,x
        rts
; --- $D394  Drift between the edges, and fire to either side.
jaquio_pace:
        jsr face_ryu
        lda enemy_x,x
        cmp #$D0
        bcs lD3A2
        cmp #$30
        bcs lD3A5
lD3A2:
        jsr reverse_enemy
lD3A5:
        lda enemy_timer,x
        bne lD3B9
        stx $00
        jsr jaquio_left
        jsr jaquio_right
        ldx $00
        lda #$78
        sta enemy_timer,x
lD3B9:
        rts
; --- $D3BA  A fireball to his left.
jaquio_left:
        jsr jaquio_spawn
        ldy $00
        sec
        lda enemy_x,y
        sbc #$20
        sta enemy_x,x
        rts
; --- $D3C9  A fireball to his right.
jaquio_right:
        jsr jaquio_spawn
        ldy $00
        clc
        lda enemy_x,y
        adc #$20
        sta enemy_x,x
        rts
; --- $D3D8  Make one fireball.
jaquio_spawn:
        jsr alloc_enemy
        bmi lD408
        ldy $00
        sec
        lda enemy_y,y
        sbc #$20
        sta enemy_y,x
        lda #$27
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda #$C2
        sta slot_flags,x
        lda #$57
        jsr set_enemy_action
        lda #$0E
        sta sound
        lda #$00
        sta enemy_state,x
lD408:
        rts

; --- $D409  A fireball that homes in on Ryu.
jaquio_fireball:
        .word jaquio_home
; --- $D40B  Steer toward Ryu. The steer never lets up, so a shot can swing past him and come back.
jaquio_home:
        jsr home_x
        sec
        lda height
        sbc #$08
        sec
        sbc enemy_y,x
        bcs lD42B
        sec
        lda enemy_y_frac,x
        sbc #$10
        sta enemy_y_frac,x
        lda enemy_y_spd,x
        sbc #$00
        sta enemy_y_spd,x
        rts
lD42B:
        clc
        lda enemy_y_frac,x
        adc #$10
        sta enemy_y_frac,x
        lda enemy_y_spd,x
        adc #$00
        sta enemy_y_spd,x
        rts

; --- $D43D  The last boss. A large creature. Head, tail, and body can all be hit.
final_boss:
        .word final_enter
        .word final_watch
        .word final_fire
; --- $D443  Take his place, behind the scenery, with a head and a tail.
final_enter:
        lda #$83
        sta $77
        lda #$81
        sta enemy_flags
        lda #$A8
        sta enemy_x,x
        lda #$78
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        jsr load_enemy_hp
        lda facing
        ora #$20                        ; draw the body behind the scenery
        sta facing
        lda #$6C
        jsr set_enemy_action
        stx $00
        jsr spawn_head
        jsr spawn_tail
        ldx $00
        lda #$78
        sta enemy_timer,x
        lda #$01
        sta enemy_state,x
        rts
; --- $D480  Keep firing. Once the head is gone, drop down.
final_watch:
        lda $0406
        cmp #$26
        beq lD4A6
        lda #$A8
        sta enemy_y,x
        lda #$02
        sta enemy_state,x
        rts
; --- $D492  As his life drops, change his pose, and fire.
final_fire:
        lda enemy_hp,x
        cmp #$0A
        bcs lD4A6
        cmp #$05
        bcc lD4A1
        lda #$0F
        bne lD4A3
lD4A1:
        lda #$6B
lD4A3:
        jsr set_enemy_action
lD4A6:
        lda enemy_timer,x
        bne lD4BE
        stx $00
        jsr alloc_enemy
        bmi lD4B5
        jsr boss_shot
lD4B5:
        ldx $00
        lda nmi_count
        lsr
        lsr
        sta enemy_timer,x
lD4BE:
        rts
; --- $D4BF  The head.
spawn_head:
        jsr alloc_enemy
        bmi lD4F1
        lda #$26
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda #$82
        sta slot_flags,x
        lda #$7D
        sta enemy_x,x
        lda #$A8
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        lda #$5A
        jsr set_enemy_action
        lda #$00
        sta enemy_state,x
lD4F1:
        rts
; --- $D4F2  The tail.
spawn_tail:
        jsr alloc_enemy
        bmi lD524
        lda #$2B
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda #$82
        sta slot_flags,x
        lda #$88
        sta enemy_x,x
        lda #$D0
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        lda #$5B
        jsr set_enemy_action
        lda #$00
        sta enemy_state,x
lD524:
        rts

; --- $D525  The head. Same picture as the body, in front. It falls off and slides left.
final_boss_head:
        .word head_break
        .word head_slide
        .word leave_actor
; --- $D52B  When he is hurt enough, he breaks off.
head_break:
        lda enemy_hp,x
        cmp #$06
        bcs lD53F
        lda enemy_flags
        and #$7F
        ora #$40
        sta enemy_flags
        lda #$01
        sta enemy_state,x
lD53F:
        rts
; --- $D540  Once he lands, he slides away.
head_slide:
        lda enemy_touch,x
        and #$30
        beq lD55B
        lda #$6B
        jsr set_enemy_action
        lda #$FE
        sta enemy_x_spd,x
        lda #$00
        sta enemy_x_frac,x
        lda #$02
        sta enemy_state,x
lD55B:
        rts

; --- $D55C  Crescents. They arc, and they keep coming for the whole fight.
final_boss_fireballs:
        .word boss_shot_fall
; --- $D55E  A crescent, from up in front of him.
boss_shot:
        lda #$29
        sta enemy_type,x
        tay
        lda $B530,y
        sta enemy_hp,x
        lda #$C2
        sta slot_flags,x
        lda nmi_count
        sta enemy_x_frac,x
        and #$03
        eor #$FF
        clc
        adc #$01
        sta enemy_x_spd,x
        jsr chase_ryu
        lda nmi_count
        sta enemy_y_frac,x
        lda #$FC
        sta enemy_y_spd,x
        lda #$5D
        jsr set_enemy_action
        lda #$80
        sta enemy_x,x
        lda #$70
        sta enemy_y,x
        lda #$00
        sta enemy_x_sub,x
        sta enemy_y_sub,x
        lda #$1C
        sta sound
        lda #$00
        sta enemy_state,x
        rts
; --- $D5AD  The fireball falls.
boss_shot_fall:
        jmp enemy_gravity

; --- $D5B0  The tail. Its own picture. It stays put until its life is gone.
final_boss_tail:
        .word leave_actor
; --- $D5B2  This action changes nothing.
leave_actor:
        rts

; --- $D5B3  frame loop while $04B8 bit 6 or 7 is set -----------------------
hold_loop:
        lda $04B8
        and #$C0
        bne @frames
        jmp to_area_event
@frames:
        jsr wait_nmi
        jsr sprite0_split
        jsr refresh_status
        jsr player_control
        jsr scroll_stage
        jsr draw_all
        lda height
        cmp #$F8
        bcs @abort
        lda health
        beq @abort
        lda timer
        cmp #$FF
        beq @abort
        bit $04B8
        bpl @no7
        jsr boss_death
        bit $04B8
@no7:
        bvc @no6
        jsr score_leftovers
@no6:
        lda $04B8
        and #$C0
        bne @frames
        lda area
        cmp #$13
        bne @not13
        lda #$01
        bne @store
@not13:
        cmp #$14
        bne @keep
        lda #$03
        bne @store
@keep:
        lda $77
        and #$7F
@store:
        sta $77
        lda #$00
        sta weapon
        sta thrown
        lda $BE
        ora #$80
        sta $BE
        ldx #$0A                ; pause for 10 frames
@wait:
        stx $11
        jsr wait_nmi
        jsr sprite0_split
        jsr refresh_status
        ldx $11
        dex
        bne @wait
        jsr fade_out
        jmp to_area_event
@abort:
        lda #$00
        sta $04B8
        jmp lose_life


; --- $D63A  While the boss is dying, step each explosion. When the timer ends, the death is over.
boss_death:
        ldx #$07
lD63C:
        lda enemy_bits
        and bit_mask,x
        beq lD646
        jsr step_enemy
lD646:
        dex
        bpl lD63C
        dec $04B9
        bne lD659
        lda $04B8
        and #$7F
        sta $04B8
        jmp free_all_enemies
lD659:
        rts

; --- $D65A  Turn leftover ninpo, then leftover time, into points. Each one is one point.
score_leftovers:
        dec $04BA
        bpl lD694
        lda nmi_count
        and #$01
        bne lD66A
        lda #$13
        sta sound
lD66A:
        lda #$02
        sta $04BA
        lda ninpo
        beq lD678
        dec ninpo
        jmp add_point
lD678:
        lda timer
        beq lD68C
        dec timer
; --- $D67E  Add one point.
add_point:
        clc
        lda score
        adc #$01
        sta score
        lda score_hi
        adc #$00
        sta score_hi
        rts
lD68C:
        lda $04B8
        and #$BF
        sta $04B8
lD694:
        rts

; --- $D695  Place four explosions around the boss.
boss_burst:
        stx $00
        lda #$40
        sta sound
        lda #$00
        sta thrown
        lda bit_mask,x
        and enemy_bits
        sta enemy_bits
        lda #$FF
        sta $04B9
        jsr one_explosion
        ldy $00
        sec
        lda enemy_x,y
        sbc #$10
        sta enemy_x,x
        sec
        lda enemy_y,y
        sbc #$18
        sta enemy_y,x
        jsr one_explosion
        ldy $00
        clc
        lda enemy_x,y
        adc #$0C
        sta enemy_x,x
        sec
        lda enemy_y,y
        sta enemy_y,x
        jsr one_explosion
        ldy $00
        sec
        lda enemy_x,y
        sbc #$10
        sta enemy_x,x
        sec
        lda enemy_y,y
        sbc #$08
        sta enemy_y,x
        jsr one_explosion
        ldy $00
        clc
        lda enemy_x,y
        adc #$10
        sta enemy_x,x
        sec
        lda enemy_y,y
        sbc #$14
        sta enemy_y,x
        rts

; --- $D707  Add one explosion.
one_explosion:
        jsr alloc_enemy
        lda #$52
        jsr set_enemy_action
        rts

; --- $D710  thrown weapons, the Hourglass, and the Invincible Fire-Wheel
move_weapon:
        bit hourglass_on                         ; Hourglass
        bpl lD72E
        dec $04C7
        bne lD72E
        dec $04C8
        beq lD72A
        lda #$1B
        sta sound
        lda #$3C                        ; one second
        sta $04C7
        bne lD72E
lD72A:
        lda #$00
        sta hourglass_on                         ; Hourglass ends
lD72E:
        lda weapon
        cmp #$84                        ; Invincible Fire-Wheel
        beq lD753
        lda thrown
        and #$07
        beq lD752
        lda weapon
        cmp #$82                        ; Windmill Throwing Star
        beq lD76E
        ldx #$02
lD742:
        lda thrown
        and bit_mask,x
        beq lD74F
        jsr move_one_thrown
        jsr step_thrown
lD74F:
        dex
        bpl lD742
lD752:
        rts
lD753:
        dec $04C7
        bne lD76B
        lda #$3C
        sta $04C7
        lda #$16
        sta sound
        dec $04C8
        bne lD76B
        lda #$00
        sta weapon
lD76B:
        jmp step_thrown
lD76E:
        ldx #$00
        jsr move_one_thrown
        jsr step_thrown
        bit $04BD
        bpl lD7AF
        sec
        lda $04BB
        sbc ryu_x
        cmp #$10
        bcs lD79B
        sec
        lda height
        sbc $04BE
        cmp #$10
        bcs lD79B
        lda thrown
        and #$FE
        sta thrown
        lda #$0D
        sta sound
        rts
lD79B:
        sec
        lda height
        sbc #$0A
        sec
        sbc $04BE
        bpl lD7AC
        dec $04BE
        jmp lD7AF
lD7AC:
        inc $04BE
lD7AF:
        sec
        lda $04BB
        sbc ryu_x
        bmi lD7D0
        sec
        lda $04C2
        sbc #$80
        sta $04C2
        lda $04C1
        sbc #$00
        sta $04C1
        bpl lD7CF
        lda #$80
        sta $04BD
lD7CF:
        rts
lD7D0:
        clc
        lda $04C2
        adc #$80
        sta $04C2
        lda $04C1
        adc #$00
        sta $04C1
        bmi lD7E8
        lda #$80
        sta $04BD
lD7E8:
        rts
; --- $D7E9  The next picture of a thrown weapon.
step_thrown:
        lda $CB
        beq lD7F0
        dec $CB
        rts
lD7F0:
        lda $CA
        asl
        tay
        lda #$02
        jsr set_prg
        lda $8600,y
        sta $00
        lda $8601,y
        sta $01
        ldy $CC
        lda ($00),y
        bne lD80C
        tay
        lda ($00),y
lD80C:
        sta $CB
        iny
        lda ($00),y
        sta $CD
        iny
        tya
        sta $CC
        rts
; --- $D818  Move this thrown weapon. The Invincible Fire-Wheel stays on Ryu.
move_one_thrown:
        lda weapon
        cmp #$84                        ; Invincible Fire-Wheel
        beq lD843
        clc
        lda $04BB,x
        adc $04C1,x
        cmp #$08
        bcc lose_thrown
        cmp #$F8
        bcs lose_thrown
        sta $04BB,x
        clc
        lda $04BE,x
        adc $04C4,x
        cmp #$F8
        bcs lose_thrown
        cmp #$40
        bcc lose_thrown
        sta $04BE,x
        rts
lD843:
        lda #$80
        sta $04BB
        sta $04BE
        rts
; --- $D84C  This thrown weapon left the screen.
lose_thrown:
        lda bit_mask,x
        eor #$FF
        and thrown
        sta thrown
        bne lD85C
        lda #$0D
        sta sound
lD85C:
        rts

; --- $D85D  Draw a thrown weapon.
draw_thrown:
        lda weapon
        cmp #$84                        ; Invincible Fire-Wheel
        beq lD884
        ldx #$02
lD865:
        lda thrown
        and bit_mask,x
        beq lD880
        lda $04BB,x
        sta $36
        sec
        lda $04BE,x
        sbc #$08
        sta $37
        stx $CE
        jsr draw_thrown_pic
        ldx $CE
lD880:
        dex
        bpl lD865
        rts
lD884:
        lda $04C8
        cmp #$04
        bcs lD893
        lda $04C7
        and #$01
        beq lD893
        rts
lD893:
        lda ryu_flags
        and #$40
        sta $34
        bne lD89F
        lda #$FD
        bmi lD8A1
lD89F:
        lda #$03
lD8A1:
        clc
        adc ryu_x
        sta $36
        sec
        lda height
        sbc #$10
        sta $37
; --- $D8AD  Draw this thrown weapon's picture.
draw_thrown_pic:
        lda $CD
        asl
        tay
        lda $8400,y
        sta $30
        lda $8401,y
        sta $31
        lda $8500,y
        sta $32
        lda $8501,y
        sta $33
        ldy #$00
        sty $35
        sty $39
        lda ($30),y
        sta $3A
        iny
        sty $38
        jmp draw_sprite

; --- $D8D5  Hang a lantern when the screen reaches it.
spawn_lanterns:
        ldx #$00
        stx MMC1_PRG
        inx
        stx MMC1_PRG
        dex
        stx MMC1_PRG
        stx MMC1_PRG
        stx MMC1_PRG
        bit scroll_flags
        bmi lD906                       ; moving left, so watch the left edge
        ldy $C7
        cpy $C1
        bcs lD965
        lda ($9C),y
        cmp screen_right                ; his column reached the right edge
        bne lD965
        clc
        lda $C7
        adc #$01
        sta $C7
        sty $00
        ldy #$FF                        ; hang on the right edge
        jmp hang_lantern
lD906:
        ldy $C6
        beq lD90B
        dey
lD90B:
        ldx screen_col
        inx
        txa
        cmp ($9C),y                     ; his column reached the left edge
        bne lD965
        sty $C6
        sty $00
        ldy #$00                        ; hang on the left edge
; --- $D919  Hang it on the edge the screen is moving toward.
hang_lantern:
        lda $00
        and #$03
        tax
        lda bit_mask,x
        and lantern_bits
        bne lD965
        lda bit_mask,x
        ora lantern_bits
        sta lantern_bits
        tya
        sta $04D9,x
        lda $A2
        sta $04D5,x
        ldy $00
        lda ($9E),y
        and #$0F
        sta $04C9,x
        lda ($9E),y
        and #$F0
        sta $04E1,x
        tya
        sta $04F1,x
        stx $01
        lda $00
        and #$07
        tax
        lda $00
        lsr
        lsr
        lsr
        tay
        lda bit_mask,x
        and $04F5,y
        beq lD966
        ldx $01
        lda #$08
        sta $04D1,x
lD965:
        rts
lD966:
        lda bit_mask,x
        ora $04F5,y
        sta $04F5,y
        ldx $01
        lda #$00
        sta $04D1,x
        rts
; --- $D977  Nothing calls this. A room that does not scroll would hang every lantern at once.
hang_still_room:
        lda scroll_pages
        beq lD9B8
        rts
; --- $D97C  No lanterns are out.
clear_lanterns:
        ldx #$05
        lda #$00
lD980:
        sta $04F5,x
        dex
        bpl lD980
        sta lantern_bits
        rts
; --- $D989  Scrolling left, this lantern left the screen.
drop_lantern_left:
        dec $C7
        jmp drop_lantern
; --- $D98E  Scrolling right, this lantern left the screen.
drop_lantern_right:
        inc $C6
; --- $D990  Take this lantern down.
drop_lantern:
        lda bit_mask,x
        eor #$FF
        and lantern_bits
        sta lantern_bits
        lda $04D1,x
        and #$0C
        bne lD9B7
        ldy $04F1,x
        tya
        and #$07
        tax
        tya
        lsr
        lsr
        lsr
        tay
        lda bit_mask,x
        eor #$FF
        and $04F5,y
        sta $04F5,y
lD9B7:
        rts
lD9B8:
        ldy $AE10,x
        bmi lD9E3
lD9BD:
        lda bit_mask,y
        ora lantern_bits
        sta lantern_bits
        lda bit_mask,y
        ora $04F5
        sta $04F5
        lda ($9C),y
        sta $04D9,y
        lda ($9E),y
        and #$0F
        sta $04C9,y
        lda ($9E),y
        and #$F0
        sta $04E1,y
        dey
        bpl lD9BD
lD9E3:
        rts

; --- $D9E4  a lantern, or the power-up falling out of it
move_lanterns:
        lda lantern_bits
        and #$0F
        bne lD9EB
        rts
lD9EB:
        dec $C3
        bpl lDA15
        lda $C2
        asl
        tay
        lda #$02
        jsr set_prg
        lda $8600,y
        sta $13
        lda $8601,y
        sta $14
        ldy $C5
        lda ($13),y
        bne lDA0B
        tay
        lda ($13),y
lDA0B:
        sta $C3
        iny
        lda ($13),y
        sta $C4
        iny
        sty $C5
lDA15:
        ldx #$03
lDA17:
        lda lantern_bits
        and bit_mask,x
        beq lDA90
        lda $04D1,x
        sta $01
        and #$08
        bne lDA90
        lda $01
        and #$04
        beq lDA7D
        jsr take_powerup
        dec $04ED,x
        beq lDA9A
        lda $01
        and #$10
        bne lDA8B
        lda $04E1,x
        sta $02
        clc
        lda $A3
        and #$0F
        adc $04D9,x
        jsr tile_at
        lda lE122,y
        and #$30
        bne lDA94
        clc
        lda $04DD,x
        adc $04E5,x
        sta $04DD,x
        lda $04E1,x
        adc $04E9,x
        cmp #$F0
        bcs lDA9A
        sta $04E1,x
        clc
        lda $04E5,x
        adc #$37
        sta $04E5,x
        lda $04E9,x
        adc #$00
        sta $04E9,x
        jmp lDA8B
lDA7D:
        jsr slash_lantern
        lda $01
        and #$04
        bne lDA8B
        lda $C4
        sta $04CD,x
lDA8B:
        lda $01
        sta $04D1,x
lDA90:
        dex
        bpl lDA17
        rts
lDA94:
        lda $01
        ora #$10
        bne lDA9E
lDA9A:
        lda $01
        ora #$08
lDA9E:
        sta $04D1,x
        rts

; --- $DAA2  sword or thrown weapon breaks the lantern, and the power-up falls out
slash_lantern:
        lda pose
        cmp #$07                        ; this frame hits
        beq lDABE
        cmp #$27                        ; this frame hits
        beq lDABE
        lda action
        cmp #$07                        ; spinning sword
        bne lDAB5
        jmp break_lantern
lDAB5:
        lda weapon
        cmp #$84                        ; Invincible Fire-Wheel
        bne lDB11
        jmp break_lantern
lDABE:
        bit ryu_flags
        bvs lDACE
        sec
        lda $04D9,x
        sbc ryu_x
        cmp #$20
        bcc lDAD8
        bcs lDB11
lDACE:
        sec
        lda ryu_x
        sbc $04D9,x
        cmp #$20
        bcs lDB11
lDAD8:
        sec
        lda height
        sbc #$08
        sec
        sbc $04E1,x
        bpl lDAE8
        eor #$FF
        clc
        adc #$01
lDAE8:
        cmp #$10
        bcs lDB11
        jmp drop_powerup
; --- $DAEF  The spinning sword or the Invincible Fire-Wheel is close enough.
break_lantern:
        sec
        lda $04D9,x
        sbc ryu_x
        bpl lDAFC
        eor #$FF
        clc
        adc #$01
lDAFC:
        cmp #$10
        bcs lDB11
        sec
        lda $04E1,x
        sbc height
        bpl lDB0D
        eor #$FF
        clc
        adc #$01
lDB0D:
        cmp #$11
        bcc drop_powerup
lDB11:
        lda thrown
        and #$07
        beq lDB84
        lda weapon
        and #$7F
        tay
        lda $E605,y
        sta $CE
        lda $E609,y
        sta $CF
        ldy #$02
lDB28:
        lda thrown
        and bit_mask,y
        beq lDB85
        sec
        lda $04D9,x
        sbc $04BB,y
        bpl lDB3D
        eor #$FF
        clc
        adc #$01
lDB3D:
        cmp $CE
        bcs lDB85
        sec
        lda $04E1,x
        sbc $04BE,y
        bpl lDB4F
        eor #$FF
        clc
        adc #$01
lDB4F:
        cmp $CE
        bcs lDB85
        lda #$15
        sta sound
        lda weapon
        cmp #$82                        ; Windmill Throwing Star keeps going
        beq drop_powerup
        lda bit_mask,y
        eor #$FF
        and thrown
        sta thrown
; --- $DB67  The lantern breaks, and the power-up falls out.
drop_powerup:
        ldy $04C9,x
        lda $E60D,y
        sta $04CD,x
        lda $E619,y
        ora #$04
        ora $01
        sta $01
        lda #$00
        sta $04E5,x
        sta $04E9,x
        sta $04ED,x
lDB84:
        rts
lDB85:
        dey
        bpl lDB28
        rts

; --- $DB89  Ryu picks up the power-up
take_powerup:
        sec
        lda ryu_x
        sbc $04D9,x
        bpl lDB96
        eor #$FF
        clc
        adc #$01
lDB96:
        cmp #$0C
        bcs lDBC8
        sec
        lda height
        sbc $04E1,x
        bpl lDBA7
        eor #$FF
        clc
        adc #$01
lDBA7:
        cmp #$11
        bcs lDBC8
        lda #$13
        sta sound
        lda $01
        ora #$08
        sta $01
        lda $04C9,x
        asl
        tay
        lda pickup_kind,y
        sta $17
        lda pickup_kind+1,y
        sta $18
        jmp ($0017)
lDBC8:
        rts

; --- $DBC9  what the power-up does. The number is its id.
pickup_kind:
        .word add_ninpo_5               ; 0
        .word add_ninpo_10              ; 1
        .word one_up                    ; 2
        .word add_health                ; 3
        .word hourglass                 ; 4
        .word add_score_5               ; 5
        .word add_score_10              ; 6
        .word invincible_fire_wheel     ; 7
        .word throwing_star             ; 8
        .word windmill_throwing_star    ; 9
        .word art_of_the_fire_wheel     ; 10
        .word jump_and_slash            ; 11

; --- $DBE1  Add 5 ninpo, up to 99.
add_ninpo_5:
        lda #$05
        bne lDBE7

; --- $DBE5  Add 10 ninpo, up to 99.
add_ninpo_10:
        lda #$0A
lDBE7:
        clc
        adc ninpo
        cmp #$64
        bcc lDBF0
        lda #$63
lDBF0:
        sta ninpo
        lda #$13
        sta sound
        rts

; --- $DBF8  1-UP
one_up:
        inc lives
        lda #$14
        sta sound
        rts

; --- $DC00  Add 6 to Ryu's health, up to full.
add_health:
        clc
        lda health
        adc #$06
        cmp #$10
        bcc lDC0B
        lda #$10
lDC0B:
        sta health
        lda #$15
        sta sound
        rts

; --- $DC13  Add 5 to the score.
add_score_5:
        lda #$05
        bne lDC19

; --- $DC17  Add 10 to the score.
add_score_10:
        lda #$0A
lDC19:
        clc
        adc score
        sta score
        lda #$00
        adc score_hi
        sta score_hi
        lda #$13
        sta sound
        rts

; --- $DC2A  Hourglass. Freeze every enemy for about five seconds.
hourglass:
        lda #$80
        sta hourglass_on                         ; Hourglass
        lda #$3C
        sta $04C7
        lda #$05                        ; five seconds
        sta $04C8
        lda weapon
        cmp #$84                        ; Invincible Fire-Wheel
        bne lDC42
        lda #$00
        sta weapon
lDC42:
        lda #$13
        sta sound
        rts

; --- $DC48  Invincible Fire-Wheel. A flame circles Ryu, and enemies cannot hurt him.
invincible_fire_wheel:
        lda #$84                        ; Invincible Fire-Wheel
        sta weapon
        lda #$68
        sta $CA
        lda #$00
        sta $CB
        sta $CC
        sta thrown
        sta hourglass_on                         ; Hourglass ends
        lda #$60
        sta $04C7
        lda #$08
        sta $04C8
        bne lDC7E

; --- $DC66  Equip the Throwing Star.
throwing_star:
        lda #$81                        ; Throwing Star
        sta weapon
        bne lDC7E

; --- $DC6C  Equip the Windmill Throwing Star.
windmill_throwing_star:
        lda #$82                        ; Windmill Throwing Star
        sta weapon
        bne lDC7E

; --- $DC72  Equip the Art of the Fire Wheel.
art_of_the_fire_wheel:
        lda #$80                        ; Art of the Fire Wheel
        sta weapon
        bne lDC7E

; --- $DC78  Equip the Jump & Slash, a spinning sword. Attack while jumping spends ninpo; it ends when he lands. Down and attack is the regular sword and spends nothing.
jump_and_slash:
        lda #$85                        ; Jump & Slash
        sta weapon
        bne lDC7E
lDC7E:
        lda #$00
        sta thrown
        lda #$13
        sta sound
        rts

; --- $DC88  Draw the lanterns on screen.
draw_lanterns:
        ldx #$03
lDC8A:
        lda lantern_bits
        and bit_mask,x
        beq lDCEA
        lda $04D1,x
        and #$08
        bne lDCEA
        stx $00
        lda $04D9,x
        sta $36
        sec
        lda $04E1,x
        sbc #$08
        sta $37
        lda $04CD,x
        asl
        tay
        lda $8400,y
        sta $30
        lda $8401,y
        sta $31
        lda $8500,y
        sta $32
        lda $8501,y
        sta $33
        lda #$00
        sta $34
        lda $04D1,x
        and #$03
        sta $35
        ldy #$00
        sty $39
        iny
        sty $38
        iny
        sty $3A
        clc
        ldy $35
        lda pickup_picture,y
        adc $32
        sta $32
        lda $33
        adc #$00
        sta $33
        jsr draw_sprite
        ldx $00
lDCEA:
        dex
        bpl lDC8A
        rts

; --- $DCEE  Which picture this pickup uses.
pickup_picture:
        .byte $00, $02, $04, $06

; --- $DCF2  Draw the equipped weapon next to the life bar.
draw_weapon_icon:
        lda weapon
        beq lDD2B
        and #$07
        tax
        lda weapon_icon,x
        asl
        tay
        lda $8400,y
        sta $30
        lda $8401,y
        sta $31
        lda $8500,y
        sta $32
        lda $8501,y
        sta $33
        ldy #$00
        sty $34
        sty $35
        sty $39
        iny
        sty $38
        iny
        sty $3A
        lda #$70
        sta $36
        lda #$27
        sta $37
        jmp draw_sprite
lDD2B:
        rts

; --- $DD2C  Picture of each equipped weapon.
weapon_icon:
        .byte $1E, $1B, $1C, $21, $1F, $1D

; --- $DD32  Give the enemies on screen a turn.
run_enemies:
        lda #$00
        jsr set_prg
        ldy #$07
        ldx #$00
        lda enemy_bits
lDD3D:
        lsr
        bcc lDD41
        inx
lDD41:
        dey
        bpl lDD3D
        stx enemy_count
        lda enemy_turns,x
        sta $74
        ldx $75
lDD4D:
        lda enemy_bits
        and bit_mask,x
        beq lDD57
        jsr enemy_turn
lDD57:
        dex
        bpl lDD5C
        ldx #$07
lDD5C:
        dec $74
        bpl lDD4D
        stx $75
        rts

; --- $DD63  How many enemies get a turn. Every count is 7.
enemy_turns:
        .byte $07, $07, $07, $07, $07, $07, $07, $07
        .byte $07

; --- $DD6C  One enemy's turn.
enemy_turn:
        lda slot_flags,x
        sta enemy_flags
        and #$10
        beq lDD98
        lda enemy_pose,x
        cmp #$44
        bne lDD81
        lda enemy_delay,x
        beq lDD84
lDD81:
        jmp step_enemy
lDD84:
        ldy enemy_type,x
        lda $B500,y
        clc
        adc score
        sta score
        lda score_hi
        adc #$00
        sta score_hi
        jmp free_enemy
lDD98:
        bit hourglass_on                         ; Hourglass
        bmi lDDD1
        lda enemy_type,x
        asl
        tay
        lda actor_kind,y
        sta $70
        lda actor_kind+1,y
        sta $71
        lda slot_facing,x
        sta facing
        jsr do_enemy_action
        bit enemy_flags
        bmi lDDC3
        jsr sense_floor
        lda enemy_flags
        and #$04
        beq lDDC3
        jsr enemy_gravity
lDDC3:
        jsr move_enemy
        lda enemy_timer,x
        beq lDDCE
        dec enemy_timer,x
lDDCE:
        jsr step_enemy
lDDD1:
        lda ryu_flags
        and #$02
        bne lDDE9
        lda weapon
        cmp #$84                        ; Invincible Fire-Wheel
        beq lDDE9
        lda action
        cmp #$07
        beq lDDE9
        jsr hurt_ryu
        nop
        nop
        nop
lDDE9:
        lda pose
        cmp #$07
        beq lDDF3
        cmp #$0A
        bne lDDF6
lDDF3:
        jsr sword_hit
lDDF6:
        lda weapon
        cmp #$84                        ; Invincible Fire-Wheel
        beq lDE02
        lda action
        cmp #$07
        bne lDE08
lDE02:
        jsr spin_hit
        jmp lDE20
lDE08:
        lda thrown
        and #$07
        beq lDE20
        lda weapon
        and #$7F
        tay
        lda $E605,y
        sta $CE
        lda $E609,y
        sta $CF
        jsr thrown_hit
lDE20:
        lda facing
        sta slot_facing,x
        lda enemy_flags
        sta slot_flags,x
        rts

; --- $DE2B  Face Ryu.
face_ryu:
        sec
        lda enemy_x,x
        sbc ryu_x
        bcc lDE39
        lda facing
        ora #$40
        bne lDE3D
lDE39:
        lda facing
        and #$BF
lDE3D:
        sta facing
        rts

; --- $DE40  Face this new one toward Ryu.
face_spawn:
        sec
        lda enemy_x,x
        sbc ryu_x
        bcc lDE51
        lda slot_facing,x
        ora #$40
        sta slot_facing,x
        rts
lDE51:
        lda slot_facing,x
        and #$BF
        sta slot_facing,x
        rts

; --- $DE5A  If he is walking away from Ryu, turn him around.
chase_ryu:
        ldy enemy_x_spd,x
        sec
        lda enemy_x,x
        sbc ryu_x
        bcs lDE6A
        tya
        bpl lDE7A
        bmi lDE6D
lDE6A:
        tya
        bmi lDE7A
lDE6D:
        ldy enemy_x_frac,x
        jsr negate_speed
        sta enemy_x_spd,x
        tya
        sta enemy_x_frac,x
lDE7A:
        rts

; --- $DE7B  The spinning sword or the fire wheel takes a point of health.
spin_hit:
        ldy enemy_pose,x
        sec
        lda enemy_x,x
        sbc ryu_x
        bmi lDE92
        sec
        sbc $B300,y
        bmi lDE9E
        sec
        sbc #$0C
        bmi lDE9E
        rts
lDE92:
        clc
        adc $B300,y
        bpl lDE9E
        clc
        adc #$08
        bpl lDE9E
        rts
lDE9E:
        sec
        lda enemy_y,x
        sbc height
        bmi lDEAD
        sec
        sbc $B400,y
        bmi lDEB3
        rts
lDEAD:
        clc
        adc #$18
        bpl lDEB3
        rts
lDEB3:
        sec
        lda enemy_hp,x
        sbc #$01
        bcs lDEBE
        jmp enemy_dies
lDEBE:
        sta enemy_hp,x
        tay
        lda #$3F
        sta sound
        lda enemy_flags
        lsr
        bcc lDECE
        sty boss_hp
lDECE:
        rts

; --- $DECF  This sword swing takes a point of health.
sword_hit:
        ldy enemy_pose,x
        bit ryu_flags
        bvs lDEFA
        sec
        lda enemy_x,x
        sbc $B300,y
        sec
        sbc ryu_x
        cmp #$20
        bcs lDEF9
        sec
        lda enemy_y,x
        sbc height
        bpl lDEF5
        eor #$FF
        clc
        adc #$01
        cmp $91
        bcc lDF1F
lDEF5:
        cmp $92
        bcc lDF1F
lDEF9:
        rts
lDEFA:
        sec
        lda ryu_x
        sbc $B300,y
        sec
        sbc enemy_x,x
        cmp #$20
        bcs lDF1E
        sec
        lda enemy_y,x
        sbc height
        bmi lDF15
        cmp $92
        bcc lDF1F
        rts
lDF15:
        eor #$FF
        clc
        adc #$01
        cmp $91
        bcc lDF1F
lDF1E:
        rts
lDF1F:
        sec
        lda enemy_hp,x
        sbc #$01
        beq enemy_dies
        bmi enemy_dies
        sta enemy_hp,x
        tay
        lda #$3F
        sta sound
        lda enemy_flags
        lsr
        bcc lDF39
        sty boss_hp
lDF39:
        rts
; --- $DF3A  Out of health. A boss starts the death cinematic. Anyone else falls.
enemy_dies:
        lda enemy_flags
        lsr
        bcc grunt_dies                  ; not a boss
        lda #$00
        sta boss_hp
        ldy enemy_type,x
        lda $B500,y
        clc
        adc score                       ; his points
        sta score
        lda #$00
        adc score_hi
        sta score_hi
        lda #$C0
        sta $04B8                       ; death cinematic
        lda area
        cmp #$13
        beq lDF65
        cmp #$14
        beq lDF69
        bne lDF6F
lDF65:
        lda #$01
        bne lDF6B
lDF69:
        lda #$02
lDF6B:
        ora $77
        sta $77
lDF6F:
        jmp boss_burst
grunt_dies:
        lda #$3C
        jsr set_enemy_action            ; his death
        lda enemy_flags
        ora #$10                        ; dying
        sta enemy_flags
        lda #$00
        sta facing
        lda #$12
        sta sound
        rts

; --- $DF87  A is 0 when the floor ends in the direction he is walking.
floor_ahead:
        ldy enemy_touch,x
        lda enemy_x_spd,x
        bmi lDF93
        tya
        and #$10
        rts
lDF93:
        tya
        and #$20
        rts

; --- $DF97  A is 0 when he is facing Ryu.
facing_ryu:
        sec
        lda enemy_x,x
        sbc ryu_x
        bcc lDFA5
        bit facing
        bvs lDFE3
        bvc lDFE6
lDFA5:
        bit facing
        bvc lDFE3
        bvs lDFE6

; --- $DFAB  Carry means Ryu is at least A pixels away, sideways.
ryu_away:
        sta $00
        sec
        lda enemy_x,x
        sbc ryu_x
        bpl lDFBA
        eor #$FF
        clc
        adc #$01
lDFBA:
        cmp $00
        rts

; --- $DFBD  A is 0 when he is moving toward Ryu.
toward_ryu:
        lda enemy_x_spd,x
        tay
        sec
        lda enemy_x,x
        sbc ryu_x
        bcc lDFCE
        tya
        bmi lDFE3
        bpl lDFE6
lDFCE:
        tya
        bpl lDFE3
        bmi lDFE6

; --- $DFD3  A is 0 when no wall blocks the direction he is walking.
wall_ahead:
        ldy enemy_touch,x
        lda enemy_x_spd,x
        bmi lDFDF
        tya
        and #$40
        rts
lDFDF:
        tya
        and #$80
        rts
lDFE3:
        lda #$00
        rts
lDFE6:
        lda #$FF
        rts

; --- $DFE9  Step this enemy's animation.
step_enemy:
        lda enemy_delay,x
        beq lDFF2
        dec enemy_delay,x
        rts
lDFF2:
        lda enemy_action,x
        asl
        tay
        lda #$02
        jsr set_prg
        lda $8600,y
        sta $13
        lda $8601,y
        sta $14
        ldy enemy_step,x
        lda ($13),y
        bne lE010
        tay
        lda ($13),y
lE010:
        sta enemy_delay,x
        iny
        lda ($13),y
        sta enemy_pose,x
        iny
        tya
        sta enemy_step,x
        lda #$00
        jsr set_prg
        rts

; --- $E024  Move him. Remove him if he leaves the screen.
move_enemy:
        bit enemy_flags
        bmi move_flyer                  ; he flies
        bvc after_walk                  ; not walking
        jsr wall_ahead
        bne after_walk                  ; a wall is in the way
        jsr move_x
after_walk:
        lda enemy_flags
        and #$04
        beq stay_put                    ; on the ground
move_y:
        clc
        lda enemy_y_sub,x
        adc enemy_y_frac,x
        sta enemy_y_sub,x
        lda enemy_y,x
        adc enemy_y_spd,x
        sta enemy_y,x
        cmp #$F8
        bcs enemy_gone                  ; below the screen
        cmp #$30
        bcc enemy_gone                  ; above the screen
stay_put:
        rts
move_x:
        clc
        lda enemy_x_sub,x
        adc enemy_x_frac,x
        sta enemy_x_sub,x
        lda enemy_x,x
        adc enemy_x_spd,x
        cmp #$08
        bcc enemy_gone                  ; off the left
        cmp #$F8
        bcs enemy_gone                  ; off the right
        sta enemy_x,x
        rts
move_flyer:
        bvc move_y
        jsr move_x
        jmp move_y
enemy_gone:
        jmp free_enemy

; --- $E07B  See what he is touching.
sense_floor:
        ldy enemy_pose,x
        lda $B300,y
        lsr
        sta $00
        lda #$00
        sta $01
        lda enemy_y,x
        tay
        and #$C0
        beq lE0EA
        sty $02
        clc
        lda $A3
        and #$0F
        adc enemy_x,x
        sta $03
        clc
        adc $00
        sta $05
        sec
        lda $03
        sbc $00
        sta $07
        lda enemy_y_spd,x
        bmi lE0C9
        lda $05
        jsr tile_at
        lda lE122,y
        and #$10
        ora $01
        sta $01
        lda $07
        jsr tile_at
        lda lE122,y
        and #$20
        ora $01
        sta $01
lE0C9:
        dec $02
        lda enemy_x_spd,x
        bmi lE0DE
        lda $05
        jsr tile_at
        lda lE122,y
        and #$40
        ora $01
        bne lE0EA
lE0DE:
        lda $07
        jsr tile_at
        lda lE122,y
        and #$80
        ora $01
lE0EA:
        sta enemy_touch,x
        and #$30
        beq lE10D
        lda enemy_flags
        and #$04
        beq lE10C
        lda enemy_flags
        and #$FB
        sta enemy_flags
        lda enemy_y,x
        and #$08
        bne lE10C
        lda enemy_y,x
        and #$F0
        sta enemy_y,x
lE10C:
        rts
lE10D:
        lda enemy_flags
        and #$04
        bne lE121
        lda enemy_flags
        ora #$04
        sta enemy_flags
        lda #$00
        sta enemy_y_frac,x
        sta enemy_y_spd,x
lE121:
        rts

lE122:
        .byte $00, $80, $40, $C0, $B0, $70, $F0, $30
        .byte $F0, $40, $00, $00, $00, $00, $00, $00

; --- $E132  Pull this enemy down.
enemy_gravity:
        clc
        lda enemy_y_frac,x
        adc #$37
        sta enemy_y_frac,x
        lda enemy_y_spd,x
        adc #$00
        sta enemy_y_spd,x
        rts

; --- $E144  If this enemy is touching Ryu, knock him back and take health.
hurt_ryu:
        ldy enemy_pose,x
        lda #$01
        sta $94
        sec
        lda enemy_x,x
        sbc ryu_x
        bpl lE15A
        dec $94
        eor #$FF
        clc
        adc #$01
lE15A:
        cmp $B300,y
        bpl lE16B
        sec
        lda height
        sbc enemy_y,x
        bmi lE16C
        cmp $90
        bcc lE177
lE16B:
        rts
lE16C:
        eor #$FF
        clc
        adc #$01
        cmp $B400,y
        bcc lE177
        rts
lE177:
        lda #$11
        sta sound
        lda ryu_flags
        ldy $94
        bne lE186
        ora #$40
        bne lE188
lE186:
        and #$BF
lE188:
        ora #$07
        sta ryu_flags
        lda knockback
        ora #$C0
        sta knockback
        lda #$3C
        sta hurt_time
        lda #$00
        sta height_frac
        lda #$FD
        sta speed_y
        lda #$00
        sta speed_x_frac
        lda #$01
        sta speed_x
        ldy enemy_type,x
        sec
        lda health
        sbc $B560,y
        sta health                      ; take health
        beq lE1B6
        bmi lE1B6
        rts
lE1B6:
        lda downed
        ora #$40
        sta downed
        rts

; --- $E1BD  Reverse this enemy's sideways speed.
reverse_enemy:
        ldy enemy_x_frac,x
        lda enemy_x_spd,x
        jsr negate_speed
        sta enemy_x_spd,x
        tya
        sta enemy_x_frac,x
        rts

; --- $E1CE  A thrown weapon takes health.
thrown_hit:
        ldy #$02
lE1D0:
        lda thrown
        and bit_mask,y
        beq lE22C
        sec
        lda enemy_x,x
        sbc $04BB,y
        bpl lE1E5
        eor #$FF
        clc
        adc #$01
lE1E5:
        cmp $CE
        bcs lE22C
        sec
        lda enemy_y,x
        sbc $04BE,y
        bpl lE1F7
        eor #$FF
        clc
        adc #$01
lE1F7:
        cmp $CE
        bcs lE22C
        lda enemy_flags
        lsr
        bcs lE206
        lda weapon
        cmp #$82                        ; Windmill Throwing Star keeps going
        beq lE20F
lE206:
        lda bit_mask,y
        eor #$FF
        and thrown
        sta thrown
lE20F:
        sec
        lda enemy_hp,x
        sbc $CF
        beq lE230
        bmi lE230
        sta enemy_hp,x
        sta $00
        lda #$3F
        sta sound
        lda enemy_flags
        lsr
        bcc lE22C
        lda $00
        sta boss_hp
lE22C:
        dey
        bpl lE1D0
        rts
lE230:
        jmp enemy_dies

; --- $E233  Flip the direction of a speed.
negate_speed:
        eor #$FF
        sta $3F
        tya
        eor #$FF
        tay
        iny
        bne lE240
        inc $3F
lE240:
        lda $3F
        rts

; --- $E243  Do the action this enemy is on.
do_enemy_action:
        lda enemy_state,x
        asl
        tay
        lda ($70),y
        sta $00
        iny
        lda ($70),y
        sta $01
        jmp ($0000)

; --- $E254  Start that action for the enemy. A picks it.
set_enemy_action:
        cmp enemy_action,x
        beq lE284
        sta enemy_action,x
        asl
        tay
        lda #$02
        jsr set_prg
        lda $8600,y
        sta $13
        lda $8601,y
        sta $14
        ldy #$00
        lda ($13),y
        sta enemy_delay,x
        iny
        lda ($13),y
        sta enemy_pose,x
        iny
        tya
        sta enemy_step,x
        lda #$00
        jsr set_prg
lE284:
        rts

; --- $E285  How much health this enemy starts with.
load_enemy_hp:
        ldy enemy_type,x
        lda $B530,y
        sta enemy_hp,x
        rts

; --- $E28F  Jump. A is the upward speed.
enemy_jump:
        sta enemy_y_spd,x
        lda #$00
        sta enemy_y_frac,x
        lda enemy_flags
        ora #$04
        sta enemy_flags
        rts
; --- $E29E  Nothing calls this. It would mark the saved flags airborne.
unused_enemy_jump:
        sta enemy_y_spd,x
        lda #$00
        sta enemy_y_frac,x
        lda slot_flags,x
        ora #$04
        sta slot_flags,x
        rts

; --- $E2AF  Take a free enemy slot. X is $FF when none are free.
alloc_enemy:
        ldx #$07
        lda enemy_bits
lE2B3:
        asl
        bcc lE2BA
        dex
        bpl lE2B3
        rts
lE2BA:
        lda bit_mask,x
        ora enemy_bits
        sta enemy_bits
        txa
        rts

; --- $E2C3  Remove this enemy.
free_enemy:
        lda slot_flags,x
        and #$02
        bne lE2E5
        stx $00
        ldy $04B0,x
        tya
        and #$07
        tax
        tya
        lsr
        lsr
        lsr
        tay
        lda bit_mask,x
        eor #$FF
        and a:$00B7,y
        sta a:$00B7,y
        ldx $00
lE2E5:
        lda #$00
        sta facing
        sta enemy_flags
        sta slot_flags,x
        sta enemy_state,x
        sta slot_facing,x
        sta enemy_x_frac,x
        sta enemy_x_spd,x
        sta enemy_y_frac,x
        sta enemy_y_spd,x
        lda bit_mask,x
        eor #$FF
        and enemy_bits
        sta enemy_bits
        rts

; --- $E30A  Remove every enemy.
free_all_enemies:
        lda #$00
        sta enemy_bits
        ldx #$07
lE310:
        jsr free_enemy
        dex
        bpl lE310
        sta $B7
        sta $B8
        sta $B9
        sta $BA
        rts

; --- $E31F  Add A to its sideways speed, in the direction it faces.
enemy_thrust:
        bit facing
        bvs lE333
        clc
        adc enemy_x_frac,x
        sta enemy_x_frac,x
        lda enemy_x_spd,x
        adc #$00
        sta enemy_x_spd,x
        rts
lE333:
        sta $00
        sec
        lda enemy_x_frac,x
        sbc $00
        sta enemy_x_frac,x
        lda enemy_x_spd,x
        sbc #$00
        sta enemy_x_spd,x
        rts

; --- $E347  The area is over. Play its cutscene, then load the next area.
; Act I is area 0. The Barbarian is area 1. After he dies: a cutscene, the Act II title card, another cutscene, then stage 2-1.
; Area 2 is those scenes, not stage 2-1. A table value of 8 can skip the cutscene and advance the area instead.
area_event:
        bit $BE
        bpl @back
        lda ppuctrl_shadow
        sta $7B
        lda ppumask_shadow
        sta $7C
        lda $56
        sta $7D
        lda $59
        sta $7E
        lda prg_bank
        sta $7F
        lda #$25
        sta sound
        lda #$00
        jsr set_prg
        ldx area
        ldy $AF9A,x
        cpy #$08
        bne @call4
        lda $77
        lsr
        bcc @call4
        lsr
        bcc @once
        inc area
@once:
        inc area
        lda #$00
        sta $BE
        jsr next_area
        jmp to_play
@call4:
        sty $BE
        lda #$04
        jsr set_prg
        tya
        jsr play_cutscene               ; this area's cutscene
        lda $7B
        sta ppuctrl_shadow
        lda $7C
        sta ppumask_shadow
        lda $7D
        sta $56
        lda $7E
        sta $59
        lda $7F
        sta prg_bank
        lda #$10
        sta health              ; full health
        jsr fill_both_nametables
        jsr next_area
@back:
        jmp to_play

; --- $E3B4  end of the play frame. Timer $FF or downed sends us to lose_life.
frame_gate:
        lda timer
        cmp #$FF
        beq lose_life
        bit downed
        bmi lose_life
        bvc @play
        lda ryu_flags
        and #$01
        beq lose_life
@play:
        jmp to_hold

; --- $E3C9  lose a life. lives counts down from 2; below 0 waits for Start. --
lose_life:
        lda $77
        bpl @same_area
        and #$7F
        sta $77
        ldx area
        cpx #$13
        bcc @prev
        ldx #$10
        bne @set_area
@prev:
        dex
@set_area:
        lda #$00
        jsr set_prg
        lda $AF2C,x
        sta room
        stx area
@same_area:
        lda #$00
        sta downed
        sta thrown
        sta weapon
        sta room_back
        sta hourglass_on                         ; Hourglass ends
        lda #$10
        sta health              ; full health
        lda #$23
        sta sound
        lda #$14
        sta pose
        dec lives
        bmi @over
        lsr ninpo               ; halve ninpo
        ldx #$BE
@retry:
        txa
        pha
        jsr wait_nmi
        jsr sprite0_split
        jsr draw_all
        pla
        tax
        dex
        bne @retry
        jsr blank_palette
        jsr prepare_area
        jsr load_room
        lda #$00
        jsr set_prg
        ldx area
        lda $AFC6,x
        sta sound
        jsr load_area_colors
        jsr show_packet
        jmp to_hold
@over:
        ldx area
        lda #$00
        jsr set_prg
        lda $AF2C,x
        sta room
        lda #$00
        sta score
        sta score_hi
        sta ninpo
        lda #$02
        sta lives
        lda #$0F                ; NMI packet at $0700: 16 bytes to PPU $3F00
        sta $0703
        sta $0707
        sta $070B
        sta $070F
        lda #$26
        sta $0704
        lda #$30
        sta $0705
        lda #$0F
        sta $0706
        lda #$10
        sta $0700
        lda #$00
        sta $0701
        lda #$3F
        sta $0702
        lda #$00
        sta $0713
        ldx #$1F                ; fade entries from bank 0, $B000
@fade:
        txa
        pha
        lda #$00
        jsr set_prg
        lda $B000,x
        sta $0708
        lda $B001,x
        sta $0709
        lda $B002,x
        sta $070A
        lda $B003,x
        sta $070C
        lda $B004,x
        sta $070D
        lda $B005,x
        sta $070E
        lda $B006,x
        sta $0710
        lda $B007,x
        sta $0711
        lda $B008,x
        sta $0712
        lda #$00
        sta packet
        lda #$07
        sta packet+1
        ldx #$05
@fade_frame:
        txa
        pha
        jsr wait_nmi
        jsr sprite0_split
        jsr draw_all
        pla
        tax
        dex
        bne @fade_frame
        pla
        tax
        dex
        bpl @fade
        lda #$10
        sta $59
        jsr clear_sprites
        jsr fill_both_nametables
        lda #$00
        jsr show_screen
        jsr wait_nmi
        lda #$02
        jsr show_screen
@start:
        lda pad_edge
        and #$10                ; Start
        beq @start
        lda #$00
        sta $A3
        lda #$10
        sta $5A
        jsr blank_palette
        jsr wait_nmi
        lda #$00
        jsr set_prg
        ldx area
        lda $AFC6,x
        sta sound
        jsr prepare_area
        jsr load_room
        jsr load_area_colors
        jsr show_packet
        jmp to_hold

; --- $E526  called from reset. Tail-jumps to reset_cont. -------------------
boot_banks:
        lda #$04
        jsr set_prg
        lda #$00
        jsr play_cutscene       ; the opening
        lda #$00
        sta $56                 ; CHR bank 0 value NMI writes
        jsr fill_both_nametables
        nop
        nop
        nop
        lda #$02
        sta lives               ; 3 lives; lose_life counts down through 0
        lda #$10
        sta health              ; full health
        lda #$00
        jsr set_prg             ; bank 0 at $8000
        ldx area
        lda $AF2C,x
        sta room
        lda $AFC6,x
        sta sound
        jsr prepare_area
        jsr load_room
        jsr fade_in
        jmp reset_cont

; --- $E560  When the screen reaches an enemy, put him on screen.
spawn_enemies:
        bit hourglass_on                         ; Hourglass
        bmi lE5B2
        bit $B4
        bmi lE5B2
        lda screen_col
        sta $00
        lda scroll_flags
        eor from_right                  ; which end of the room he came from
        sta $04
        bpl lE58C
        bit from_right
        bpl lE581
        clc
        lda screen_col
        adc #$0E
        sta $00
        bne lE58C
lE581:
        sec
        lda screen_col
        sbc #$0D
        bpl lE58A
        lda #$00
lE58A:
        sta $00
lE58C:
        lda #$02
        jsr set_prg
        ldx #$07
        ldy $B5
lE595:
        lda ($96),y
        cmp $00
        bne lE5A6
        stx $05
        sty $06
        jsr place_enemy
        ldx $05
        ldy $06
lE5A6:
        iny
        cpy $B4
        bcc lE5AD
        ldy #$00
lE5AD:
        sty $B5
        dex
        bpl lE595
lE5B2:
        rts
; --- $E5B3  Put this enemy on screen, unless he is already out.
place_enemy:
        sty $01
        tya
        and #$07
        tax
        tya
        lsr
        lsr
        lsr
        tay
        lda bit_mask,x
        and a:$B7,y
        bne lE604
        stx $02
        sty $03
        jsr alloc_enemy
        cpx #$FF
        beq lE604
        ldy $01
        lda ($98),y
        asl
        asl
        asl
        asl
        bit $04
        bpl lE5E2
        eor #$FF
        clc
        adc #$01
lE5E2:
        sta enemy_x,x
        ldy $01
        lda ($98),y
        and #$F0
        sta enemy_y,x
        lda ($9A),y
        sta enemy_type,x
        tya
        sta $04B0,x
        ldx $02
        ldy $03
        lda bit_mask,x
        ora a:$B7,y
        sta a:$B7,y
lE604:
        rts

lE605:
        .byte $0E, $0E, $12, $20, $01, $01, $01, $02, $19, $19, $1A, $20, $21, $22, $22, $1F
        .byte $1B, $1C, $1E, $1D, $00, $01, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00

; --- $E625  Step Ryu's animation.
step_ryu:
        dec ryu_delay
        bne lE65F
        lda action
        asl
        tay
        lda #$02
        jsr set_prg
        lda $8600,y
        sta $13
        lda $8601,y
        sta $14
        ldy ryu_step
        lda ($13),y
        beq lE64F
        bmi lE660
        sta ryu_delay
        iny
        lda ($13),y
        iny
        sta pose
        sty ryu_step
        rts
lE64F:
        lda #$00
        sta action
        lda ryu_flags
        and #$F7
        sta ryu_flags
        lda #$00
        sta pose
        sta ryu_step
lE65F:
        rts
lE660:
        ldy #$00
        lda ($13),y
        sta ryu_delay
        iny
        lda ($13),y
        sta pose
        iny
        sty ryu_step
        rts

; --- bit_mask  One bit in each byte.
bit_mask:
        .byte $01, $02, $04, $08, $10, $20, $40, $80

; --- $E677  See whether Ryu is against a wall or on steps.
touch_walls:
        lda height
        cmp #$48
        bcs lE67E
        rts
lE67E:
        lda touching
        and #$80
        sta touching
        lda #$00
        sta $00
        clc
        lda $A3
        and #$0F
        adc ryu_x
        sta $01
        sec
        lda height
        sbc #$05
        sta $02
        sta $04
        clc
        lda $01
        adc #$05
        sta $05
        jsr tile_at
        cpy #$0A
        bcc lE6AB
        jmp exit_tile
lE6AB:
        lda ground_flag,y
        sta $8E
        sec
        lda height
        sbc #$01
        sta $02
        sta $07
        lda $05
        jsr tile_at
        lda ground_flag,y
        sta $8F
        lda $04
        sta $02
        sec
        lda $01
        sbc #$09
        sta $05
        jsr tile_at
        cpy #$0A
        bcc lE6D8
        jmp exit_tile
lE6D8:
        lda ground_flag,y
        sta $03
        lda $07
        sta $02
        lda $05
        jsr tile_at
        lda ground_flag,y
        sta $04
        bit touching
        bpl lE705
        lda $8E
        ora $8F
        and #$2A
        bne lE739
        lda $03
        ora $04
        and #$0A
        bne lE739
        lda #$00
        sta touching
        beq lE739
lE705:
        lda $8F
        and #$23
        ora touching
        sta touching
        lda $8F
        and #$23
        bne lE71F
        lda $8E
        and #$2A
        beq lE71F
        lda touching
        ora #$80
        sta touching
lE71F:
        lda $04
        and #$0C
        ora touching
        sta touching
        lda $04
        and #$0C
        bne lE739
        lda $03
        and #$2A
        beq lE739
        lda touching
        ora #$80
        sta touching
lE739:
        bit speed_y
        bmi lE768
        lda height
        sta $02
        clc
        lda $01
        adc #$03
        jsr tile_at
        lda ground_flag,y
        and #$10
        bne lE75F
        sec
        lda $01
        sbc #$07
        jsr tile_at
        lda ground_flag,y
        and #$10
        beq lE768
lE75F:
        lda touching
        and #$F5
        ora #$10
        sta touching
        rts
lE768:
        lda touching
        and #$22
        bne lE77B
        lda touching
        and #$08
        beq lE77A
        lda ryu_flags
        ora #$40
        sta ryu_flags
lE77A:
        rts
lE77B:
        lda ryu_flags
        and #$BF
        sta ryu_flags
        rts

; --- $E782  What each kind of ground does to Ryu.
ground_flag:
        .byte $00, $0C, $03, $0F, $1C, $13, $1F, $10, $15, $20, $00, $00, $00, $00, $00, $00

; --- $E792  The ground tile at this spot.
tile_at:
        lsr
        lsr
        lsr
        lsr
        tay
        clc
        lda ground_col,y
        adc ground_i
        bcs lE7A3
        cmp #$C0
        bcc lE7A6
lE7A3:
        sec
        sbc #$C0
lE7A6:
        sta $00
        sec
        lda $02
        sbc #$40
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc $00
        tay
        lda $0300,y
        tay
        lda $02
        and #$10
        bne lE7C7
        tya
        lsr
        lsr
        lsr
        lsr
        tay
        rts
lE7C7:
        tya
        and #$0F
        tay
        rts

; --- $E7CC  Where each column of the ground map starts.
ground_col:
        .byte $00, $06, $0C, $12, $18, $1E, $24, $2A, $30, $36, $3C, $42, $48, $4E, $54, $5A

; --- $E7DC  fill nametables $2000 and $2400 with $FF ----------------------
fill_both_nametables:
        lda #$FF
        ldx #$20
        pha
        jsr fill_nametable
        ldx #$24
        pla
fill_nametable:
        ldy #$00
        sty PPUCTRL             ; rendering off, increment +1
        sty PPUMASK
        bit PPUSTATUS
        stx PPUADDR
        sty PPUADDR
        ldx #$C0                ; $3C0 name bytes, then $40 attributes
        ldy #$04
@name:
        sta PPUDATA
        dex
        bne @name
        dey
        bne @name
        txa
        ldx #$40
@attr:
        sta PPUDATA
        dex
        bne @attr
        lda ppumask_shadow
        sta PPUMASK
        lda ppuctrl_shadow
        sta PPUCTRL
        rts

; --- $E819  pad -> pad_cur. D0 OR D1 each bit (Famicom expansion). --------
read_joy:
        ldx #$01
        stx JOY1
        dex
        stx JOY1
        ldx #$08
@bit:
        lda JOY1
        sta $20
        lsr
        ora $20
        lsr
        rol pad_cur
        dex
        bne @bit
        rts

; --- $E833  Move Ryu. The stage stays put.
move_ryu:
        lda pad_cur
        lsr
        bcc lE846
        lda touching
        and #$2B
        bne lE858
        lda ryu_x
        cmp #$F0
        bcs lE858
        bne step_right
lE846:
        lsr
        bcc lE858
        lda touching
        and #$2E
        bne lE858
        lda ryu_x
        cmp #$10
        bcc lE858
        jmp step_left
lE858:
        rts
; --- $E859  Move Ryu right.
step_right:
        clc
        lda ryu_x_frac
        adc speed_x_frac
        sta ryu_x_frac
        lda ryu_x
        adc speed_x
        sta ryu_x
        rts
; --- $E867  Move Ryu left.
step_left:
        sec
        lda ryu_x_frac
        sbc speed_x_frac
        sta ryu_x_frac
        lda ryu_x
        sbc speed_x
        sta ryu_x
        rts
; --- $E875  Tile kind $0A and up. This one sends Ryu on.
exit_tile:
        bit downed
        bvs lE898
        tya
        sec
        sbc #$0A
        asl
        tay
        lda $E88C,y
        sta $17
        lda $E88D,y
        sta $18
        jmp ($0017)

lE88C:
        .word lE898
        .word lE898
        .word finish_area
        .word lE8D2
        .word lE8EA
        .word lE8A0

lE898:
        rts
; --- $E899  Mark the area finished.
finish_area:
        lda $BE
        ora #$80                        ; the area is finished
        sta $BE
        rts
lE8A0:
        lda #$25
        sta sound
        jsr fade_out
; --- $E8A8  Load the next area.
next_area:
        ldx area
        inx
        stx area
        lda #$00
        jsr set_prg
        lda $AF2C,x
        sta room
        jsr prepare_area
        jsr load_room
        lda #$00
        jsr set_prg
        ldx area
        lda $AF2C,x
        sta room
        lda $AFC6,x
        sta sound
        jmp fade_in
lE8D2:
        inc room
        lda #$00
        sta room_back
        jsr clear_sprites
        jsr blank_palette
        jsr wait_nmi
        jsr load_room
        jsr load_area_colors
        jmp show_packet
lE8EA:
        dec room
        lda #$80
        sta room_back
        jsr clear_sprites
        jsr blank_palette
        jsr wait_nmi
        jsr load_room
        jsr load_area_colors
        jmp show_packet
; --- $E902  Load this room's layout.
load_room:
        jsr blank_palette
        jsr clear_sprites
        lda #$00
        jsr set_prg
        lda room
        tax
        asl
        tay
        lda $AC30,y
        sta ground_ptr
        lda $AC31,y
        sta ground_ptr_hi
        lda #$00
        sta ground_i
        lda $AC90,x
        and #$0F
        sta $56
        sta $57
        lda $AD20,x
        sta $00
        and #$7F
        sta scroll_pages
        lda $00
        and #$80
        sta from_right
        eor room_back
        sta $17
        bpl lE97F
        lda #$60
        sta $5D
        lda $00
        and #$7F
        sta stage_x_hi
        lda $00
        and #$0F
        asl
        tax
        clc
        lda ground_ptr
        adc $E95F,x
        sta ground_ptr
        lda ground_ptr_hi
        adc $E960,x
        sta ground_ptr_hi
        bne lE985

lE95F:
        .word $0090
        .word $00C0
        .word $00F0
        .word $0120
        .word $0150
        .word $0180
        .word $01B0
        .word $01E0
        .word $0210
        .word $0240
        .word $0270
        .word $02A0
        .word $02B0
        .word $0300
        .word $0330
        .word $0360

lE97F:
        lda #$00
        sta $5D
        sta stage_x_hi
lE985:
        lda #$03
        sta $5E
        lda #$00
        sta scroll_flags
        sta $67
        sta $69
        sta speed_x_frac
        lda #$10
        sta speed_x
        lda #$12
        bit $17
        bmi lE9C0
        ldx #$00
        stx $68
        stx $6A
        ldx #$00
        stx $6B
        ldx #$21
        stx $6C
lE9AB:
        sta $10
        jsr scroll_on_right
        jsr wait_nmi
        jsr sprite0_split
        lda $10
        tax
        dex
        txa
        bne lE9AB
        jmp place_ryu
lE9C0:
        ldx #$07
        stx $68
        stx $6A
        ldx #$00
        stx $6B
        ldx #$25
        stx $6C
lE9CE:
        sta $10
        jsr scroll_on_left
        jsr wait_nmi
        jsr sprite0_split
        lda $10
        tax
        dex
        txa
        bne lE9CE
; --- $E9E0  The room is on screen. Put Ryu where it starts.
place_ryu:
        lda #$00
        sta scroll_frac
        sta stage_x
        sta $A0
        sta $A1
        sta $A2
        sta $A3
        sta speed_x_frac
        sta speed_x
        sta $A6
        sta touching
        sta ryu_x_frac
        sta $88
        sta $4A
        sta $4B
        lda ppuctrl_shadow
        and #$FE
        sta ppuctrl_shadow
        lda #$04
        sta sprite_slot
        ldx room
        bit room_back
        bmi lEA1A
        lda $AD50,x
        sta ryu_x
        lda $AD80,x
        sta height
        bne lEA24
lEA1A:
        lda $ADB0,x
        sta ryu_x
        lda $ADE0,x
        sta height
lEA24:
        bit ryu_x
        bmi lEA2C
        lda #$00
        beq lEA2E
lEA2C:
        lda #$40
lEA2E:
        sta ryu_flags
        lda #$02
        jsr set_prg
        lda room
        tax
        asl
        tay
        lda $8700,y
        sta $9C
        lda $8701,y
        sta $9D
        lda $8760,y
        sta $9E
        lda $8761,y
        sta $9F
        lda $87C0,y
        sta $96
        lda $87C1,y
        sta $97
        lda $8820,y
        sta $98
        lda $8821,y
        sta $99
        lda $8880,y
        sta $9A
        lda $8881,y
        sta $9B
        lda #$00
        jsr set_prg
        lda $AE10,x
        sta $C1
        lda $AE40,x
        sta $B4
        bit $17
        bpl lEA8D
        lda $B4
        sta $B5
        sta $B6
        lda $C1
        sta $C6
        sta $C7
        bpl lEA97
lEA8D:
        lda #$00
        sta $C6
        sta $C7
        sta $B6
        sta $B5
lEA97:
        jsr free_all_enemies
        jsr clear_lanterns
        lda #$00
        sta pose
        lda #$10
        sta boss_hp
        lda #$01
        sta $0700
        lda #$C6
        sta $0701
        lda #$20
        sta $0702
        lda lives
        sta $0703
        lda #$00
        sta $0704
        jmp show_packet
; --- $EAC1  Set the clock and this area's pictures.
prepare_area:
        lda #$00
        jsr set_prg
        ldx area
        lda $AFB0,x
        sta timer
        lda $AF84,x
        sta $C2
        lda area_gfx,x
        tay
        and #$1C
        clc
        adc #$80
        sta $45                         ; which four tiles
        lda #$00
        sta $44
        tya
        and #$03
        tay
        clc
        adc #$B0
        sta $47                         ; the tile for each block
        lda #$00
        sta $46
        tya
        asl
        tay
        clc
        adc #$A4
        sta $49                         ; ground_kind, one table per area_gfx pair
        lda #$30
        sta $48
        tya
        asl
        clc
        adc #$A0
        sta $43                         ; which blocks
        lda #$00
        sta $42
        lda $AF16,x
        lsr
        lsr
        lsr
        sta $5A
        lda #$10
        sta $59
        lda #$26
        sta $0200
        lda #$00
        sta $0201
        lda #$20
        sta $0202
        lda #$A0
        sta $0203
        lda #$08
        sta $A7
        lda #$01
        jsr show_screen
        jsr wait_nmi
        lda #$00
        jsr set_prg
        lda #$03
        sta $0700
        lda #$96
        sta $0701
        lda #$20
        sta $0702
        lda $AF6E,x
        lsr
        lsr
        lsr
        lsr
        sta $0703
        lda #$18
        sta $0704
        lda $AF6E,x
        and #$0F
        sta $0705
        lda #$00
        sta $0706
        jmp show_packet
; --- $EB64  Draw Ryu, the enemies, the lanterns, and his weapon.
draw_all:
        lda #$02
        jsr set_prg
        jsr clear_sprites
        jsr draw_ryu
        jsr draw_enemies
        jsr draw_lanterns
        jsr draw_thrown
        jmp draw_weapon_icon

; --- $EB7B  move Ryu vertically, then choose his action from the controller
player_control:
        lda ryu_flags
        and #$04
        beq lEB9D
        clc
        lda height
        adc speed_y                         ; vertical speed
        sta height
        cmp #$F8                        ; below the screen
        bcc lEB90
        lda #$80
        sta downed
lEB90:
        clc
        lda height_frac
        adc #$37                        ; gravity
        sta height_frac
        lda speed_y
        adc #$00
        sta speed_y
lEB9D:
        jsr touch_walls
        jsr ryu_body
        jsr step_ryu
        bit knockback
        bpl lEBD8                       ; not knocked back
        dec hurt_time
        bne hurt_tick                   ; still knocked back
        lda ryu_flags
        and #$ED                        ; stop flickering
        sta ryu_flags
        lda #$00
        sta knockback
        beq lEBD8
hurt_tick:
        bvc lEBD8                       ; flicker already started
        lda ryu_flags
        and #$01
        bne lEBCE
        lda ryu_flags
        ora #$10                        ; start flickering
        sta ryu_flags
        lda #$80
        sta knockback
        bne lEBD8
lEBCE:
        ldx $94
        inx
        stx $28
        lda #$0B
        jmp set_action                  ; knocked back
lEBD8:
        lda touching
        and #$2A
        bne lEBF1                       ; on a wall or on steps
        lda $28
        and #$0F                        ; direction held
        asl
        tax
        lda $F087,x
        sta $17
        lda $F088,x
        sta $18
        jmp ($0017)                     ; run that direction
lEBF1:
        and #$20
        bne lEC0B                       ; on steps
        lda touching
        and #$02
        bne lEC03                       ; wall on his right
        lda $28
        cmp #$81                        ; A and Right jumps off
        beq lEC34
        bne lEC1B
lEC03:
        lda $28
        cmp #$82                        ; A and Left jumps off
        beq lEC34
        bne lEC1B
lEC0B:
        lda $28
        tax
        cmp #$82                        ; A and Left jumps off
        beq lEC34
        and #$08
        bne lEC20
        txa
        and #$04
        bne lEC2D
lEC1B:
        lda #$0A
        jmp set_action                  ; hold on
lEC20:
        lda $8E
        and #$20
        beq lEC28
        dec height                         ; climb the steps
lEC28:
        lda #$0C
        jmp set_action                  ; climbing the steps
lEC2D:
        inc height                         ; climb down the steps
        lda #$0C
        jmp set_action                  ; climbing the steps
lEC34:
        bit $04B8
        bmi lEC3E
        lda #$0F
        sta sound
lEC3E:
        lda #$00
        sta height_frac
        lda #$FE                        ; jump off
        sta speed_y
        lda ryu_flags
        eor #$40
        ora #$04
        sta ryu_flags
        jsr run_speed
        lda #$C0
        sta touching                         ; let go
        lda #$05
        jmp set_action                  ; jump off
; --- $EC5A  Nothing reaches this. Letting go of a wall without turning or hopping.
unused_wall_drop:
        bit $04B8
        bmi lEC64
        lda #$0F
        sta sound
lEC64:
        lda #$00
        sta height_frac
        sta speed_y
        lda ryu_flags
        ora #$04
        sta ryu_flags
        lda touching
        ora #$C0
        sta touching
        lda #$05
        jmp set_action

; --- $EC7B  no direction held
ctrl_idle:
        bit $29
        bvs lEC96                       ; sword button
        bmi do_jump                     ; jump button
        lda ryu_flags
        and #$0C
        bne lEC8C
        lda #$00
        jmp set_action
lEC8C:
        and #$08
        bne lEC95
        lda #$05
        jmp set_action
lEC95:
        rts
lEC96:
        lda ryu_flags
        and #$0C
        bne lECB1
        bit $04B8
        bmi lECA6
        lda #$35
        sta sound
lECA6:
        lda ryu_flags
        ora #$08
        sta ryu_flags
        lda #$03
        jmp set_action                  ; sword
lECB1:
        and #$08
        bne lECE8
        lda ryu_flags
        ora #$08
        sta ryu_flags
        lda weapon
        cmp #$85                        ; Jump & Slash
        bne lECD9
        sec
        lda ninpo
        sbc #$05                        ; ninpo - 5
        bmi lECD9
        sta ninpo
        bit $04B8
        bmi lECD4
        lda #$1A
        sta sound
lECD4:
        lda #$07
        jmp set_action                  ; spinning sword
lECD9:
        bit $04B8
        bmi lECE3
        lda #$35
        sta sound
lECE3:
        lda #$06
        jmp set_action                  ; regular sword
lECE8:
        rts

; --- $ECE9  jump
do_jump:
        lda ryu_flags
        and #$04
        bne lED0C
        bit $04B8
        bmi lECF9
        lda #$0F
        sta sound
lECF9:
        lda ryu_flags
        ora #$04
        sta ryu_flags
        lda #$00
        sta height_frac
        lda #$FC                        ; upward speed
        sta speed_y
        lda #$05
        jmp set_action
lED0C:
        rts

; --- $ED0D  holding Right
ctrl_right:
        bit $29
        bvs lED3A                       ; sword button
        bmi lED8D                       ; jump button
        lda ryu_flags
        and #$0C
        bne lED27
        jsr run_speed
        lda ryu_flags
        and #$BF                        ; face right
        sta ryu_flags
        lda #$01
        jmp set_action
lED27:
        and #$08
        bne lED30
        lda #$05
        jsr set_action
lED30:
        bit ryu_flags
        bvc lED37
        jmp drift_speed
lED37:
        jmp run_speed
lED3A:
        lda ryu_flags
        and #$0C
        bne lED55
        lda ryu_flags
        ora #$08
        sta ryu_flags
        bit $04B8
        bmi lED50
        lda #$35
        sta sound
lED50:
        lda #$03
        jmp set_action                  ; sword
lED55:
        and #$08
        bne lED8C
        lda ryu_flags
        ora #$08
        sta ryu_flags
        lda weapon
        cmp #$85                        ; Jump & Slash
        bne lED7D
        sec
        lda ninpo
        sbc #$05                        ; ninpo - 5
        bmi lED7D
        sta ninpo
        bit $04B8
        bmi lED78
        lda #$1A
        sta sound
lED78:
        lda #$07
        jmp set_action                  ; spinning sword
lED7D:
        bit $04B8
        bmi lED87
        lda #$35
        sta sound
lED87:
        lda #$06
        jmp set_action                  ; regular sword
lED8C:
        rts
lED8D:
        lda ryu_flags
        and #$04
        bne lEDB0
        bit $04B8
        bmi lED9D
        lda #$0F
        sta sound
lED9D:
        lda ryu_flags
        ora #$04
        sta ryu_flags
        lda #$00
        sta height_frac
        lda #$FC
        sta speed_y                         ; upward speed
        lda #$05
        jmp set_action
lEDB0:
        rts

; --- $EDB1  holding Left
ctrl_left:
        bit $29
        bvs lEDDE                       ; sword button
        bmi lEE31                       ; jump button
        lda ryu_flags
        and #$0C
        bne lEDCB
        jsr run_speed
        lda ryu_flags
        ora #$40                        ; face left
        sta ryu_flags
        lda #$01
        jmp set_action
lEDCB:
        and #$08
        bne lEDD4
        lda #$05
        jsr set_action
lEDD4:
        bit ryu_flags
        bvs lEDDB
        jmp drift_speed
lEDDB:
        jmp run_speed
lEDDE:
        lda ryu_flags
        and #$0C
        bne lEDF9
        bit $04B8
        bmi lEDEE
        lda #$35
        sta sound
lEDEE:
        lda ryu_flags
        ora #$08
        sta ryu_flags
        lda #$03
        jmp set_action                  ; sword
lEDF9:
        and #$08
        bne lEE30
        lda ryu_flags
        ora #$08
        sta ryu_flags
        lda weapon
        cmp #$85                        ; Jump & Slash
        bne lEE21
        sec
        lda ninpo
        sbc #$05                        ; ninpo - 5
        bmi lEE21
        sta ninpo
        bit $04B8
        bmi lEE1C
        lda #$1A
        sta sound
lEE1C:
        lda #$07
        jmp set_action                  ; spinning sword
lEE21:
        bit $04B8
        bmi lEE2B
        lda #$35
        sta sound
lEE2B:
        lda #$06
        jmp set_action                  ; regular sword
lEE30:
        rts
lEE31:
        lda ryu_flags
        and #$04
        bne lEE54
        bit $04B8
        bmi lEE41
        lda #$0F
        sta sound
lEE41:
        lda ryu_flags
        ora #$04
        sta ryu_flags
        lda #$00
        sta height_frac
        lda #$FC
        sta speed_y                         ; upward speed
        lda #$05
        jmp set_action
lEE54:
        rts

; --- $EE55  holding Down
ctrl_down:
        bit $29
        bvs lEE6A                       ; sword button
        bpl lEE5E                       ; jump button not held
        jmp do_jump
lEE5E:
        lda ryu_flags
        and #$0C
        bne lEE69
        lda #$02
        jmp set_action                  ; crouch
lEE69:
        rts
lEE6A:
        lda ryu_flags
        and #$0C
        bne lEE85
        bit $04B8
        bmi lEE7A
        lda #$35
        sta sound
lEE7A:
        lda ryu_flags
        ora #$08
        sta ryu_flags
        lda #$04
        jmp set_action                  ; sword while crouching
lEE85:
        and #$08
        bne lEE98
        bit $04B8
        bmi lEE93
        lda #$35
        sta sound
lEE93:
        lda #$06
        jmp set_action                  ; regular sword
lEE98:
        rts

; --- $EE99  holding Up
ctrl_up:
        bit $29
        bvs use_subweapon               ; sub-weapon button
        bpl lEEA2                       ; jump button not held
        jmp do_jump
lEEA2:
        lda ryu_flags
        and #$0C
        bne lEEAD
        lda #$00
        jmp set_action
lEEAD:
        rts

; --- $EEAE  use the equipped sub-weapon
use_subweapon:
        lda $04B8
        and #$C0
        bne no_throw                    ; the death cinematic
        lda ryu_flags
        and #$0C
        beq throw_ground
        and #$08
        beq throw_air                   ; in the air
        rts                             ; already swinging
throw_ground:
        lda #$08                        ; on the ground
        bne windup
throw_air:
        lda #$09
windup:
        jsr set_action
        lda ryu_flags
        ora #$08
        sta ryu_flags
        lda weapon
        cmp #$80                        ; Art of the Fire Wheel
        bne lEED8
        jmp throw_fire_wheel
lEED8:
        cmp #$81                        ; Throwing Star
        bne lEEDF
        jmp throw_star
lEEDF:
        cmp #$82                        ; Windmill Throwing Star
        bne no_throw
        jmp throw_windmill
no_throw:
        rts

; --- $EEE7  Full sideways speed, the way he is facing.
run_speed:
        lda #$80
        sta speed_x_frac
        lda #$01
        sta speed_x
        rts

; --- $EEF0  Half speed, when he holds the other way.
drift_speed:
        lda #$80
        sta speed_x_frac
        lda #$00
        sta speed_x
        rts

; --- $EEF9  Art of the Fire Wheel. Three flames, for 5 ninpo.
throw_fire_wheel:
        lda thrown
        and #$07
        bne lEF06
        sec
        lda ninpo
        sbc #$05                        ; ninpo - 5
        bpl lEF07
lEF06:
        rts
lEF07:
        sta ninpo
        lda #$07
        sta thrown                         ; three flames
        lda #$51
        sta $CA
        lda #$00
        sta $CC
        lda #$04
        bit ryu_flags
        bvc lEF1D
        lda #$FC
lEF1D:
        sta $04C1
        sta $04C2
        sta $04C3
        lda #$FA
        sta $04C4
        lda #$FC
        sta $04C5
        lda #$FE
        sta $04C6
        lda ryu_x
        sta $04BB
        sta $04BC
        sta $04BD
        lda height
        sta $04BE
        sta $04BF
        sta $04C0
        bit $04B8
        bmi lEF55
        lda #$19
        sta sound
lEF55:
        rts

; --- $EF56  Throwing Star. Flies straight, for 3 ninpo.
throw_star:
        ldx #$02
lEF58:
        lda thrown
        and bit_mask,x
        beq lEF63
        dex
        bpl lEF58
        rts
lEF63:
        sec
        lda ninpo
        sbc #$03                        ; ninpo - 3
        bpl lEF6B
        rts
lEF6B:
        sta ninpo
        lda thrown
        ora bit_mask,x
        sta thrown
        lda #$0D
        sta $CA
        lda #$00
        sta $CC
        lda #$04
        bit ryu_flags
        bvc lEF84
        lda #$FC
lEF84:
        sta $04C1,x
        lda #$00
        sta $04C4,x
        lda ryu_x
        sta $04BB,x
        sec
        lda height
        sbc #$0A
        sta $04BE,x
        bit $04B8
        bmi lEF58
        lda #$17
        sta sound
        rts

; --- $EFA4  Windmill Throwing Star. Cuts through and comes back, for 5 ninpo.
throw_windmill:
        lda thrown
        and #$07
        bne lEFB1
        sec
        lda ninpo
        sbc #$05                        ; ninpo - 5
        bpl lEFB2
lEFB1:
        rts
lEFB2:
        sta ninpo
        lda #$01
        sta thrown
        lda #$0E
        sta $CA
        lda #$00
        sta $CC
        lda #$09
        bit ryu_flags
        bvc lEFC8
        lda #$F7
lEFC8:
        sta $04C1
        lda #$00
        sta $04C2
        sta $04C4
        sta $04C5
        sta $04BD
        lda ryu_x
        sta $04BB
        sec
        lda height
        sbc #$0A
        sta $04BE
        bit $04B8
        bmi lEFF0
        lda #$18
        sta sound
lEFF0:
        rts

; --- $EFF1  Set Ryu's size, and grab a wall when he hits one.
ryu_body:
        lda action
        cmp #$02
        beq lF001
        cmp #$04
        beq lF001
        lda #$19
        sta $90
        bne lF005
lF001:
        lda #$11
        sta $90
lF005:
        lda action
        cmp #$07
        beq lF021
        cmp #$03
        beq lF029
        cmp #$06
        beq lF029
        cmp #$04
        bne lF031
        lda #$18
        sta $91
        lda #$18
        sta $92
        bne lF031
lF021:
        lda #$20
        sta $91
        sta $92
        bne lF031
lF029:
        lda #$18
        sta $91
        lda #$10
        sta $92
lF031:
        lda touching
        and #$3A
        bne lF04A
        lda ryu_flags
        and #$04
        bne lF049
        lda #$00
        sta height_frac
        sta speed_y
        lda ryu_flags
        ora #$04
        sta ryu_flags
lF049:
        rts
lF04A:
        and #$10
        bne lF069
        lda ryu_flags
        and #$04
        beq lF086
        bit $04B8
        bmi lF05E
        lda #$0F
        sta sound
lF05E:
        lda ryu_flags
        and #$F2
        sta ryu_flags
        lda #$0A
        jmp set_action
lF069:
        lda ryu_flags
        and #$04
        beq lF086
        lda height
        and #$08
        bne lF086
        lda height
        and #$F0
        sta height
        lda ryu_flags
        and #$F2
        sta ryu_flags
        lda #$00
        jmp set_action
lF086:
        rts

; --- $F087  Which way he is holding the D-pad.
direction_action:
        .word ctrl_idle
        .word ctrl_right
        .word ctrl_left
        .word ctrl_idle
        .word ctrl_down
        .word ctrl_right
        .word ctrl_left
        .word ctrl_idle
        .word ctrl_up
        .word ctrl_right
        .word ctrl_left
        .word ctrl_idle
        .word ctrl_idle
        .word ctrl_idle
        .word ctrl_idle
        .word ctrl_idle

; --- $F0A7  Draw Ryu. While he is hurt he blinks, hidden every other frame.
draw_ryu:
        lda ryu_flags
        and #$10                        ; flickering while hurt
        beq ryu_picture
        clc
        lda flicker
        adc #$80                        ; flip which frames he shows
        sta flicker
        bmi ryu_picture
        rts
; --- $F0B7  His current picture.
ryu_picture:
        lda pose
        asl
        tay
        lda $8400,y
        sta $30
        lda $8401,y
        sta $31                         ; the shape
        lda $8500,y
        sta $32
        lda $8501,y
        sta $33                         ; the colors
        lda ryu_flags
        and #$E0                        ; flip
        sta $34
        lda ryu_x
        sta $36
        sec
        lda height
        sbc #$08                        ; top of the sprite
        cmp #$F0
        bcs ryu_below                   ; below the screen
        sta $37
        ldy #$00
        sty $39
        lda ($30),y
        sta $3A                         ; how many pieces
        iny
        sty $38
        jmp draw_sprite
ryu_below:
        rts
; --- $F0F3  Show screen A, then wait.
show_screen:
        asl
        tay
        lda #$01
        jsr set_prg
        lda screen_list,y
        sta packet                      ; this screen
        lda screen_list+1,y
        sta packet+1

; --- $F104  wait until NMI sets nmi_latch, then clear it -------------------
wait_nmi:
        bit nmi_latch
        bpl wait_nmi
        lda #$00
        sta nmi_latch
        rts


; --- $F10D  Draw the enemies on screen.
draw_enemies:
        ldx #$07
next_enemy:
        lda enemy_bits
        and bit_mask,x
        beq next_slot                   ; nobody in this slot
        lda #$00
        sta $00
        lda enemy_pose,x                ; his picture
        asl
        rol $00
        sta $01
        adc #$00
        sta $17
        lda $00
        adc #$80
        sta $18
        ldy #$00
        lda ($17),y
        sta $30
        iny
        lda ($17),y
        sta $31
        clc
        lda $01
        adc #$00
        sta $17
        lda $00
        adc #$82
        sta $18
        dey
        lda ($17),y
        sta $32
        iny
        lda ($17),y
        sta $33
        lda slot_facing,x
        tay
        and #$E0                        ; flip
        sta $34
        tya
        and #$03
        sta $35
        lda enemy_x,x
        sta $36
        sec
        lda enemy_y,x
        sbc #$08                        ; top of the sprite
        sta $37
        ldy #$00
        sty $39
        lda ($30),y
        sta $3A
        iny
        sty $38
        lda #$00
        ldy $35
        beq lF18A
        clc
lF17A:
        adc $3A
        dey
        bne lF17A
        clc
        adc $32
        sta $32
        lda $33
        adc #$00
        sta $33
lF18A:
        stx $02
        jsr draw_sprite
        ldx $02
next_slot:
        dex
        bmi lF197
        jmp next_enemy
lF197:
        rts
lF198:
        bit PPUSTATUS
        bvs lF198
lF19D:
        bit PPUSTATUS
        bvc lF19D
        lda $57
        jsr set_chr0
        lda $5A
        jmp set_chr1

; --- $F1AC  If Ryu is in the middle of the screen, scroll the stage with him. Otherwise move him.
scroll_stage:
        lda stage_x_hi
        sta screen_col
        lda stage_x
        lsr screen_col
        ror
        lsr screen_col
        ror
        lsr screen_col
        ror
        lsr screen_col
        ror
        sta screen_col                  ; left edge, in 16-pixel columns
        clc
        adc #$10
        sta screen_right                ; one screen further
        lda action
        cmp #$02
        beq lF21B
        cmp #$03
        beq lF21B
        cmp #$04
        beq lF21B
        cmp #$08
        beq lF21B
        lda ryu_x
        cmp #$7F                        ; middle of the screen
        beq lF1E5
        cmp #$80
        beq lF1E5
        cmp #$81
        bne lF200
lF1E5:
        lda scroll_pages
        beq lF200                       ; this room does not scroll
        lda pad_cur
        lsr
        bcc lF1F9
        lda stage_x_hi
        beq lF203                       ; still at the left end
        cmp scroll_pages
        bne lF203                       ; not at the right end yet
        jmp move_ryu                    ; the right end of the room
lF1F9:
        lsr
        bcc lF21B
        bit stage_x_hi
        bpl lF203                       ; not past the left end
lF200:
        jmp move_ryu
lF203:
        lda pad_cur
        lsr
        bcc lF20F
        lda touching
        and #$2B
        beq scroll_right
        rts
lF20F:
        lsr
        bcc lF21B
        lda touching
        and #$2E
        bne lF21B
        jmp scroll_left
lF21B:
        rts

; --- $F21C  Scroll the stage to the right.
scroll_right:
        clc
        lda scroll_frac
        adc speed_x_frac
        sta scroll_frac
        lda stage_x
        adc speed_x
        sta stage_x
        lda stage_x_hi
        adc #$00
        sta stage_x_hi
        clc
        lda $4A
        adc speed_x_frac
        sta $4A
        lda $4B
        adc speed_x
        sta $4B
        cmp #$10
        bcc lF251
        and #$0F
        sta $4B
        clc
        lda ground_i
        adc #$06                        ; next column of the ground
        cmp #$C0
        bcc lF24F
        lda #$00
lF24F:
        sta ground_i
lF251:
        clc
        lda $A2
        adc speed_x_frac
        sta $A2
        lda $A3
        adc speed_x
        sta $A3
        bcc lF266
        lda scroll_flags
        eor #$01
        sta scroll_flags
lF266:
        clc
        lda $A4
        adc $AE
        sta $A4
        lda $A5
        adc $AF
        sta $A5
        bcc lF27B
        lda $4D
        eor #$01
        sta $4D
lF27B:
        ldx #$07
lF27D:
        lda enemy_bits
        and bit_mask,x
        beq lF29A
        sec
        lda enemy_x_sub,x
        sbc speed_x_frac
        sta enemy_x_sub,x
        lda enemy_x,x
        sbc speed_x
        sta enemy_x,x
        bcs lF29A
        jsr free_enemy
lF29A:
        dex
        bpl lF27D
        ldx #$02
lF29F:
        lda thrown
        and bit_mask,x
        beq lF2B4
        sec
        lda $04BB,x
        sbc speed_x
        sta $04BB,x
        bcs lF2B4
        jsr lose_thrown
lF2B4:
        dex
        bpl lF29F
        ldx #$03
lF2B9:
        lda lantern_bits
        and bit_mask,x
        beq lF2DA
        sec
        lda $04D5,x
        sbc speed_x_frac
        sta $04D5,x
        lda $04D9,x
        sbc speed_x
        bcs lF2D7
        stx $00
        jsr drop_lantern_right
        ldx $00
lF2D7:
        sta $04D9,x
lF2DA:
        dex
        bpl lF2B9
; --- $F2DD  Bring on the next column to the right. Loading a room calls this.
scroll_on_right:
        lda scroll_flags
        bpl lF2F2
        and #$7F
        sta scroll_flags
        clc
        lda ground_ptr
        adc #$60
        sta ground_ptr
        lda ground_ptr_hi
        adc #$00
        sta ground_ptr_hi
lF2F2:
        clc
        lda $67
        adc speed_x_frac
        sta $67
        lda $68
        adc speed_x
        sta $68
        cmp #$10
        bcc lF31D
        and #$0F
        sta $68
        jsr queue_column
        clc
        lda $6B
        adc #$02
        cmp #$20
        bne lF31B
        lda $6C
        eor #$04
        sta $6C
        lda #$00
lF31B:
        sta $6B
lF31D:
        clc
        lda $69
        adc speed_x_frac
        sta $69
        lda $6A
        adc speed_x
        sta $6A
        cmp #$20
        bcc lF34F
        and #$1F
        sta $6A
        jsr load_ground
        clc
        lda ground_ptr
        adc #$06
        sta ground_ptr
        lda ground_ptr_hi
        adc #$00
        sta ground_ptr_hi
        clc
        lda $5D
        adc #$0C
        cmp #$C0
        bcc lF34D
        lda #$00
lF34D:
        sta $5D
lF34F:
        rts

; --- $F350  Scroll the stage to the left.
scroll_left:
        sec
        lda scroll_frac
        sbc speed_x_frac
        sta scroll_frac
        lda stage_x
        sbc speed_x
        sta stage_x
        lda stage_x_hi
        sbc #$00
        sta stage_x_hi
        sec
        lda $4A
        sbc speed_x_frac
        sta $4A
        lda $4B
        sbc speed_x
        sta $4B
        bpl lF383
        and #$0F
        sta $4B
        sec
        lda ground_i
        sbc #$06
        cmp #$FA
        bne lF381
        lda #$BA
lF381:
        sta ground_i
lF383:
        sec
        lda $A2
        sbc speed_x_frac
        sta $A2
        lda $A3
        sbc speed_x
        sta $A3
        bcs lF398
        lda scroll_flags
        eor #$01
        sta scroll_flags
lF398:
        sec
        lda $A4
        sbc $AE
        sta $A4
        lda $A5
        sbc $AF
        sta $A5
        bcs lF3AD
        lda $4D
        eor #$01
        sta $4D
lF3AD:
        ldx #$07
lF3AF:
        lda enemy_bits
        and bit_mask,x
        beq lF3D3
        clc
        lda enemy_x_sub,x
        adc speed_x_frac
        sta enemy_x_sub,x
        lda enemy_x,x
        adc speed_x
        sta enemy_x,x
        bcc lF3CC
        jsr free_enemy
lF3CC:
        cmp #$F8
        bcc lF3D3
        jsr free_enemy
lF3D3:
        dex
        bpl lF3AF
        ldx #$02
lF3D8:
        lda thrown
        and bit_mask,x
        beq lF3ED
        clc
        lda $04BB,x
        adc speed_x
        sta $04BB,x
        bcc lF3ED
        jsr lose_thrown
lF3ED:
        dex
        bpl lF3D8
        ldx #$03
lF3F2:
        lda lantern_bits
        and bit_mask,x
        beq lF413
        clc
        lda $04D5,x
        adc speed_x_frac
        sta $04D5,x
        lda $04D9,x
        adc speed_x
        bcc lF410
        stx $00
        jsr drop_lantern_left
        ldx $00
lF410:
        sta $04D9,x
lF413:
        dex
        bpl lF3F2
; --- $F416  Bring on the next column to the left. Loading a room calls this.
scroll_on_left:
        lda scroll_flags
        bmi lF42B
        ora #$80
        sta scroll_flags
        sec
        lda ground_ptr
        sbc #$60
        sta ground_ptr
        lda ground_ptr_hi
        sbc #$00
        sta ground_ptr_hi
lF42B:
        sec
        lda $69
        sbc speed_x_frac
        sta $69
        lda $6A
        sbc speed_x
        sta $6A
        bpl lF459
        and #$1F
        sta $6A
        jsr load_ground
        sec
        lda ground_ptr
        sbc #$06
        sta ground_ptr
        lda ground_ptr_hi
        sbc #$00
        sta ground_ptr_hi
        sec
        lda $5D
        sbc #$0C
        bcs lF457
        lda #$B4
lF457:
        sta $5D
lF459:
        sec
        lda $67
        sbc speed_x_frac
        sta $67
        lda $68
        sbc speed_x
        sta $68
        bmi lF469
        rts
lF469:
        and #$0F
        sta $68
        sec
        lda $6B
        sbc #$02
        bpl lF47C
        lda $6C
        eor #$04
        sta $6C
        lda #$1E
lF47C:
        sta $6B

; --- $F47E  Queue the next column of the stage.
queue_column:
        lda scroll_flags
        ora #$40                        ; a column is waiting
        sta scroll_flags
        lda #$00
        sta MMC1_PRG
        sta MMC1_PRG
        sta MMC1_PRG
        sta MMC1_PRG
        sta MMC1_PRG
        lda #$01
        sta $0700
        sta $0704
        sta $0708
        sta $070C
        sta $0710
        sta $0714
        lda $6B
        lsr
        lsr
        ora #$D0
        sta $0701
        ora #$08
        sta $0705
        eor #$38
        sta $0709
        ora #$08
        sta $070D
        eor #$18
        sta $0711
        ora #$08
        sta $0715
        lda $6C
        ora #$02
        sta $0702
        sta $0706
        sta $070A
        sta $070E
        sta $0712
        sta $0716
        lda $6B
        and #$02
        ora #$01
        sta $00
        lda #$16
        sta $01
        ldy #$05
        sty $02
lF4F1:
        lda (ground_ptr),y
        sta a:$0004,y
        dey
        bpl lF4F1
        ldx #$01
        stx MMC1_PRG
        dex
        stx MMC1_PRG
        stx MMC1_PRG
        stx MMC1_PRG
        stx MMC1_PRG
lF50B:
        ldy $02
        lda a:$0004,y
        jsr copy_block
        dec $02
        bpl lF50B
        lda #$96
        sta $0718
        sta $0731
        ldx $6B
        stx $0719
        inx
        stx $0732
        lda $6C
        sta $071A
        sta $0733
        lda #$00
        sta $074A
        lda #$00
        sta packet
        lda #$07
        sta packet+1
        rts

; --- $F53E  Copy one block of tiles into that column.
copy_block:
        ldx column_slot,y
        tay
        lda ($46),y
        sta $0700,x
        tya
        ldx #$00
        stx $03
        asl
        rol $03
        asl
        rol $03
        adc $42
        sta $13
        lda $03
        adc $43
        sta $14
        ldy $00
        lda ($13),y
        jsr copy_quad
        ldy $00
        dey
        lda ($13),y
; --- $F568  A is a block. Copy its four tiles into this column.
copy_quad:
        ldx #$00
        stx $03
        asl
        rol $03
        asl
        rol $03
        adc $44
        sta $15
        lda $03
        adc $45
        sta $16
        ldy #$00
        ldx $01
        lda ($15),y
        sta $071B,x
        iny
        lda ($15),y
        sta $071C,x
        iny
        lda ($15),y
        sta $0734,x
        iny
        lda ($15),y
        sta $0735,x
        dex
        dex
        stx $01
        rts

; --- $F59C  Where each tile sits in that column.
column_slot:
        .byte $03, $07, $0B, $0F, $13, $17

; --- $F5A2  sprite-0 hit, then CHR / scroll / nametable select -------------
sprite0_split:
        bit PPUSTATUS
        bvs sprite0_split       ; wait until the hit flag clears
@wait_hit:
        bit PPUSTATUS
        bvc @wait_hit           ; wait until it sets
        lda $5A                 ; CHR bank 1
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lda $57                 ; CHR bank 0
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lda $A3
        sta PPUSCROLL
        lda $A9
        sta PPUSCROLL
        lda scroll_flags
        and #$01                ; nametable select
        ora ppuctrl_shadow
        sta PPUCTRL
        rts

; --- $F5EA  Copy what each block in this column does to Ryu.
load_ground:
        lda #$00
        sta MMC1_PRG
        sta MMC1_PRG
        sta MMC1_PRG
        sta MMC1_PRG
        sta MMC1_PRG
        ldy #$05
        sty $00
        ldy #$0B
        sty $01
lF603:
        ldy $00
        lda (ground_ptr),y
        ldy #$00
        sty $02
        asl
        rol $02
        adc $48
        sta $13
        lda $49
        adc $02
        sta $14
        lda ($13),y
        ldy $00
        sta ($5D),y
        ldy #$01
        lda ($13),y
        ldy $01
        sta ($5D),y
        dec $01
        dec $00
        bpl lF603
        rts

; --- $F62D  start this action if Ryu is not already doing it
set_action:
        cmp action
        beq lF652
        sta action
        asl
        tay
        lda #$02
        jsr set_prg
        lda $8600,y
        sta $13
        lda $8601,y
        sta $14
        ldy #$00
        lda ($13),y
        sta ryu_delay
        iny
        lda ($13),y
        sta pose
        iny
        sty ryu_step
lF652:
        rts

; --- $F653  Fade in.
fade_in:
        ldx #$1F
        lda #$0F                        ; black
black_fill:
        sta $0727,x
        dex
        bpl black_fill
        jsr load_area_colors
        ldy #$03
        lda #$0F
        sta $0F
next_shade:
        ldx #$1F
one_color:
        lda $0703,x
        and $0F                         ; this step's brightness
        sta $0727,x
        lda #$24
        sta packet
        lda #$07
        sta packet+1
        jsr wait_nmi
        jsr sprite0_split
        dex
        bpl one_color
        clc
        lda $0F
        adc #$10                        ; brighter
        sta $0F
        dey
        bpl next_shade
        rts
; --- $F68C  Fade out.
fade_out:
        jsr load_area_colors
        ldy #$03
fade_step:
        ldx #$1F
fade_color:
        sec
        lda $0703,x
        sbc #$10                        ; one step darker
        bpl keep_color
        lda #$0F                        ; black
keep_color:
        sta $0703,x
        lda #$00
        sta packet
        lda #$07
        sta packet+1
        jsr wait_nmi
        jsr sprite0_split
        dex
        bpl fade_color
        dey
        bpl fade_step
        rts
; --- $F6B5  Load this area's colors.
load_area_colors:
        lda #$04
        sta $00
        lda #$00
        sta $01
        lda #$B0
        sta $02
        lda #$00
        jsr set_prg
        sta $0701
        sta $0725
        sta $0723
        sta $0747
        jsr copy_color_set
        ldy area
        lda $AF42,y
        jsr copy_color_set
        ldy area
        lda $AF58,y
        jsr copy_color_set
        ldy area
        lda $BFE0,y
        jsr copy_color_set
        lda #$00
        sta $01
        lda #$B1
        sta $02
        lda #$00
        jsr copy_color_set
        lda #$01
        jsr copy_color_set
        ldy room
        lda $ACC0,y
        jsr copy_color_set
        ldy room
        lda $ACF0,y
        jsr copy_color_set
        ldx room
        lda $AC90,x
        lsr
        lsr
        lsr
        lsr
        tax
        lda $B200,x
        sta $0703
        sta $0707
        sta $070B
        sta $070F
        sta $0713
        sta $0717
        sta $071B
        sta $071F
        lda #$3F
        sta $0702
        sta $0726
        lda #$20
        sta $0700
        sta $0724
        rts
; --- $F745  Copy one three-color set into the packet.
copy_color_set:
        sta $03
        asl
        clc
        adc $03
        adc $01
        sta $13
        lda #$00
        adc $02
        sta $14
        ldy #$00
        ldx $00
lF759:
        lda ($13),y
        sta $0700,x
        inx
        iny
        cpy #$03
        bne lF759
        inx
        stx $00
        rts
; --- $F768  Clear every sprite except the status split.
clear_sprites:
        lda #$01
        ldx #$3F
        asl
        asl
        tay
        lda #$F0
lF771:
        sta $0200,y
        iny
        iny
        iny
        iny
        dex
        bne lF771
        rts
; --- $F77C  Draw one sprite, one piece at a time.
draw_sprite:
        clc
        lda sprite_slot
        adc #$80                        ; next sprite
        bcc place_piece
        clc
        adc #$04                        ; skip the status split
place_piece:
        sta sprite_slot
        tax
        ldy $39
        lda $34
        eor ($32),y
        sta $0202,x                     ; color and flip
        iny
        sty $39
        ldy $38
        lda ($30),y
        sta $0201,x                     ; tile
        iny
        bit $34
        bvs mirror_piece                ; facing left
        lda ($30),y
        bpl piece_right
        bmi piece_left
mirror_piece:
        lda ($30),y
        eor #$FF
        clc
        adc #$01                        ; mirror the offset
        sec
        sbc #$08
        bmi piece_left
piece_right:
        clc
        adc $36
        sta $0203,x                     ; horizontal position
        bcs hide_piece
        bcc piece_top
piece_left:
        eor #$FF
        clc
        adc #$01
        sta $3C
        sec
        lda $36
        sbc $3C
        sta $0203,x                     ; horizontal position
        bcs piece_top
hide_piece:
        iny
        lda #$F0                        ; off the screen
        bmi piece_y
piece_top:
        iny
        lda ($30),y
        clc
        adc $37
piece_y:
        sta $0200,x                     ; vertical position
        iny
        sty $38
        dec $3A                         ; pieces left
        bne draw_sprite
        rts
; --- $F7E4  Count down the clock, then refresh the status bar.
tick_clock:
        dec frames
        bpl refresh_status              ; this second is not over
        lda #$3C
        sta frames                      ; 60 frames
        sec
        lda timer
        sbc #$01
        sta timer                       ; one second off the clock
        cmp #$0A
        bcs refresh_status              ; ten seconds or more left
        lda #$1B
        sta sound
; --- $F7FC  One status field per frame: score, time, health, ninpo, the boss, lives.
refresh_status:
        dec status_i
        bpl have_field                  ; next field
        ldy #$05
        sty status_i                    ; start over
        bne write_field
have_field:
        ldy status_i
write_field:
        lda status_len,y
        sta $0700
        lda status_ppu,y
        sta $0701
        lda #$20
        sta $0702
        ldx status_stop,y
        lda #$00
        sta $0700,x
        tya
        asl
        tay
        lda status_fn,y
        sta $00
        lda status_fn+1,y
        sta $01
        jmp ($0000)
; --- $F831  Write the score.
show_score:
        lda score
        sta $00
        lda score_hi
        sta $01
        ldy #$03                        ; four digits
        jmp print_number
; --- $F83E  Write the clock.
show_time:
        lda timer
        cmp #$FF
        beq time_up                     ; time is up
        sta $00
        lda #$00
        sta $01
        ldy #$02                        ; three digits
        jmp print_number
time_up:
        rts
; --- $F850  Write ninpo.
show_ninpo:
        lda ninpo
        sta $00
        lda #$00
        sta $01
        ldy #$01                        ; two digits
        jmp print_number
; --- $F85D  Write the lives.
show_lives:
        lda lives
        sta $00
        lda #$00
        sta $01
        ldy #$01                        ; two digits
        jmp print_number
; --- $F86A  Draw his health. Eight marks, two points each.
show_health:
        ldx health
        jmp draw_bar
; --- $F86F  Draw the boss's health.
show_boss:
        ldx boss_hp
draw_bar:
        ldy #$03
        lda #$08                        ; eight marks
        sta $00
bar_mark:
        dex
        beq half_mark                   ; one point left
        bmi empty_mark                  ; nothing left
        dex
        lda #$19                        ; full
        bne store_mark
half_mark:
        lda #$1A                        ; half
        bne store_mark
empty_mark:
        lda #$1B                        ; empty
store_mark:
        sta $0700,y
        iny
        dec $00                         ; marks left
        bne bar_mark
        beq status_packet
; --- $F891  Write this number on the status bar.
print_number:
        lda #$0A
        sta $02
next_digit:
        lda #$00
        sta $03
        ldx #$10
        rol $00
        rol $01
lF89F:
        rol $03
        lda $03
        cmp $02
        bcc lF8AB
        sbc $02
        sta $03
lF8AB:
        rol $00
        rol $01
        dex
        bne lF89F
        lda $03
        sta $0703,y                     ; this digit
        dey
        lda $00
        ora $01
        bne next_digit
        tya
        bmi status_packet
        lda #$00
pad_digits:
        sta $0703,y                     ; a blank
        dey
        bpl pad_digits
status_packet:
        lda #$00
        sta packet
        lda #$07
        sta packet+1
        rts

; score, time, health, ninpo, the boss, lives
status_len:
        .byte $04, $03, $08, $02, $08, $02
status_ppu:
        .byte $89, $A9, $B6, $CA, $D6, $C5
status_stop:
        .byte $07, $06, $0B, $05, $0B, $05
status_fn:
        .word show_score, show_time, show_health, show_ninpo, show_boss, show_lives

; --- $F8F0  Fill the palette with black.
blank_palette:
        lda #$20
        sta $0700
        lda #$00
        sta $0701
        sta $0723
        lda #$3F
        sta $0702
        lda #$0F
        ldx #$1F
lF906:
        sta $0703,x
        dex
        bpl lF906
; --- $F90C  Show the packet that was just built.
show_packet:
        lda #$00
        sta packet
        lda #$07
        sta packet+1
        jsr wait_nmi
        jmp sprite0_split

; --- $F91A  NMI. IRQ vector is the RTI at the end. -------------------------
nmi:
        sta $2D
        stx $2E
        sty $2F
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAMDMA              ; $0200-$02FF
        lda packet+1
        beq @no_upload
        sta $21                 ; pointer $2B/$2C, in PRG bank 1
        lda packet
        sta $20
        ldy #$00
        sty packet+1
        ldx #$01                ; PRG bank 1 at $8000 (bits 1,0,0,0,0)
        stx MMC1_PRG
        dex
        stx MMC1_PRG
        stx MMC1_PRG
        stx MMC1_PRG
        stx MMC1_PRG
@packet:
        lda ($20),y
        tax                     ; byte count. 0 ends the list
        beq @clear_palette
        bpl @horiz
        and #$7F
        tax
        lda ppuctrl_shadow
        ora #$04                ; PPU increment 32
        bne @set_ctrl
@horiz:
        lda ppuctrl_shadow
@set_ctrl:
        sta PPUCTRL
        iny
        lda ($20),y
        sta $22
        iny
        lda ($20),y
        sta PPUADDR
        lda $22
        sta PPUADDR
        iny
@data:
        lda ($20),y
        sta PPUDATA
        iny
        dex
        bne @data
        beq @packet
@clear_palette:
        lda #$3F
        sta PPUADDR
        lda #$00
        sta PPUADDR
        sta PPUADDR
        sta PPUADDR
@no_upload:
        bit PPUSTATUS
        lda $A1
        sta PPUSCROLL
        lda $A7
        sta PPUSCROLL
        lda $56                 ; CHR bank 0
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lsr
        sta MMC1_CHR0
        lda $59                 ; CHR bank 1
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lsr
        sta MMC1_CHR1
        lda ppumask_shadow
        sta PPUMASK
        lda ppuctrl_shadow
        sta PPUCTRL
        jsr read_joy
        lda pad_cur
        sta $21
        jsr read_joy
        lda pad_cur
        cmp $21                 ; mismatch: keep the previous pad
        beq @pad_ok
        lda $2A
        sta pad_cur
@pad_ok:
        tay
        eor $2A
        and pad_cur             ; bits newly pressed
        sta pad_edge
        sty $2A
        ldx #$01                ; PRG bank 3 (bits 1,1,0,0,0), call it, restore
        stx MMC1_PRG
        stx MMC1_PRG
        dex
        stx MMC1_PRG
        stx MMC1_PRG
        stx MMC1_PRG
        jsr $8000               ; play the sounds
        lda prg_bank
        sta MMC1_PRG
        lsr
        sta MMC1_PRG
        lsr
        sta MMC1_PRG
        lsr
        sta MMC1_PRG
        lsr
        sta MMC1_PRG
        ldy $2F
        ldx $2E
        lda #$FF
        sta nmi_latch
        inc nmi_count
        lda $2D
irq:
        rti

lFA20:
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
; --- $FC00  Kick drum.
kick_drum:
        .byte $9A, $71, $96, $99, $A3, $69, $96, $99, $F9, $88, $9D, $9B, $99, $CD, $66, $DA
        .byte $CA, $B0, $B3, $44, $CB, $71, $1C, $83, $3C, $F8, $07, $00, $01, $F8, $07, $C0
        .byte $1F, $C0, $03, $42, $F6, $87, $18, $5F, $F3, $A5, $EB, $3F, $93, $DF, $BF, $E4
        .byte $BD, $F9, $7D, $8B, $B7, $37, $F3, $7C, $9C, $F9, $1C, $A5, $13, $97, $66, $99
        .byte $6A, $54, $62, $44, $49, $C1, $12, $91, $78, $04, $6A, $32, $02, $33, $0B, $46
        .byte $1A, $93, $91, $61, $5A, $14, $5B, $26, $99, $CC, $64, $E5, $16, $95, $AB, $95
        .byte $E3, $1C, $6B, $99, $CB, $CB, $99, $E6, $69, $D6, $6C, $36, $9B, $CB, $A9, $39
        .byte $DB, $B8, $72, $B9, $5C, $4E, $2D, $A7, $93, $E5, $A9, $E1, $CC, $65, $B1, $5A
        .byte $55, $39, $A9, $B5, $52, $AB, $52, $55, $99, $59, $56, $E5, $64, $5A, $59, $59
        .byte $66, $56, $55, $55, $55, $99, $55, $8E, $65, $69, $99, $B2, $9C, $2C, $47, $93
        .byte $33, $D5, $54, $55, $59, $A6, $A6, $CA, $C9, $D4, $4C, $56, $99, $E5, $A8, $9A
        .byte $CA, $AA, $26, $53, $D3, $58, $A5, $A9, $2C, $4D, $65, $A9, $32, $95, $C5, $CC
        .byte $94, $A9, $2A, $53, $95, $69, $2A, $CB, $32, $53, $55, $D5, $38, $35, $D5, $D2
        .byte $AC, $AA, $65, $96, $AB, $D4, $AC, $95, $59, $35, $AB, $AA, $56, $55, $B5, $AA
        .byte $AA, $5A, $55, $35, $AB, $AA, $6A, $56, $55, $55, $B5, $AA, $AA, $9A, $A9, $65
        .byte $59, $55, $55, $55, $55, $55, $55, $55, $55, $55, $96, $65, $66, $6A, $AA, $AA
; --- $FD00  Snare.
snare:
        .byte $AA, $AA, $AA, $02, $C4, $87, $1F, $83, $FF, $F9, $FF, $FF, $19, $0F, $00, $00
        .byte $00, $30, $C0, $00, $FF, $33, $BF, $1F, $FC, $07, $FF, $1F, $FF, $FD, $CF, $87
        .byte $C1, $01, $10, $00, $00, $00, $80, $03, $3E, $EE, $E3, $E7, $F8, $DF, $7F, $FE
        .byte $C7, $4F, $FF, $01, $FC, $C0, $0F, $00, $00, $0F, $00, $0A, $E7, $70, $90, $0F
        .byte $F8, $B3, $BF, $FF, $C3, $9F, $FC, $18, $0F, $BE, $61, $3E, $F8, $70, $0C, $07
        .byte $81, $21, $28, $38, $84, $07, $77, $F0, $F8, $E7, $F7, $F1, $FE, $E0, $37, $FC
        .byte $C1, $F8, $80, $97, $C0, $0F, $5C, $61, $D0, $38, $C0, $03, $8F, $E8, $0F, $77
        .byte $B8, $07, $FB, $7C, $E0, $C3, $FD, $E0, $83, $F7, $E0, $07, $3F, $1C, $0E, $C6
        .byte $C1, $30, $05, $3E, $F0, $03, $1F, $FC, $04, $7F, $E0, $0F, $7E, $70, $3E, $F8
        .byte $DD, $F0, $07, $7E, $F0, $C1, $1F, $90, $19, $8E, $E0, $C1, $03, $1F, $04, $1F
        .byte $FC, $C1, $0F, $9E, $E8, $C7, $3C, $5E, $0F, $7F, $74, $87, $AB, $03, $0F, $0F
        .byte $74, $0C, $3E, $88, $2E, $98, $0F, $F4, $81, $1F, $38, $0E, $1F, $FC, $E2, $2D
        .byte $F9, $AC, $1F, $3E, $CC, $87, $8D, $07, $1E, $0F, $0E, $3C, $88, $47, $D8, $C1
        .byte $83, $07, $7E, $F0, $70, $EC, $0E, $E7, $E3, $F1, $E5, $E1, $17, $8F, $D1, $8B
        .byte $0E, $27, $DC, $18, $39, $1C, $F8, $C0, $83, $C3, $F0, $C3, $86, $6D, $49, $3B
        .byte $8E, $CF, $E1, $3B, $CE, $83, $77, $E1, $07, $6E, $0A, $7E, $D0, $23, $78, $42
        .byte $47, $F4, $E0, $38, $B8, $E1, $E2, $19, $8F, $C7, $39, $9E, $F2, $E1, $2D, $3E
        .byte $3A, $1E, $AB, $1C, $95, $A3, $C5, $1C, $4A, $8D, $52, $C3, $E4, $22, $1B, $7C
        .byte $E4, $96, $D2, $87, $C7, $E7, $F0, $59, $35, $2F, $8E, $D5, $78, $70, $B1, $71
        .byte $E8, $D0, $14, $2E, $A3, $43, $B3, $E2, $34, $7C, $68, $1E, $7A, $E1, $63, $AB
        .byte $D6, $CA, $93, $5E, $1C, $57, $79, $38, $19, $CD, $E1, $44, $17, $65, $38, $C3
        .byte $CA, $0A, $6B, $5A, $CA, $8B, $CE, $E1, $93, $8F, $BA, $A9, $2B, $7A, $B1, $95
        .byte $E9, $E0, $25, $2B, $6A, $49, $F1, $C1, $11, $8F, $86, $4E, $AE, $78, $F0, $85
        .byte $AB, $55, $E5, $C5, $CE, $52, $4F, $B6, $1C, $B5, $3C, $78, $B8, $D8, $C4, $72
        .byte $A8, $45, $4B, $16, $9D, $4A, $1E, $F1, $61, $B5, $B2, $56, $B5, $EC, $78, $5C
        .byte $36, $B3, $34, $AB, $C9, $45, $3A, $69, $31, $3A, $AA, $6A, $2C, $56, $EA, $70
        .byte $2A, $47, $C7, $46, $67, $63, $73, $78, $3A, $CD, $6A, $55, $E5, $D2, $D4, $B4
        .byte $54, $15, $47, $17, $E5, $28, $1E, $5A, $C9, $9A, $B4, $AC, $AC, $96, $6A, $35
        .byte $3E, $DC, $54, $AD, $69, $66, $A3, $55, $59, $55, $A5, $19, $53, $D3, $98, $46
        .byte $1D, $AA, $0E, $5B, $B2, $E3, $22, $1F, $AE, $D2, $D1, $55, $BA, $E8, $B1, $5C
        .byte $A6, $36, $5A, $55, $96, $26, $1B, $BA, $54, $78, $54, $63, $55, $65, $A5, $6A
        .byte $56, $8E, $4B, $CD, $A9, $8E, $BA, $86, $A7, $6A, $9A, $6A, $A5, $6A, $8A, $47
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; --- $FFDA  reset vector lands here. The INC targets its own opcode
; (ROM, so the byte does not change) and falls through.
reset_stub:
        inc reset_stub
        jmp reset

lFFE0:
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; --- $FFFA -----------------------------------------------------------------
        .word nmi, reset_stub, irq
